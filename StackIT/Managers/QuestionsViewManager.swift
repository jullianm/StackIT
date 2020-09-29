//
//  ViewModel.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import Combine
import Foundation
import StackAPI

class QuestionsViewManager: ObservableObject {
    /// Published properties
    @Published var tags: [TagSummary] = TagSummary.popular
    @Published var questionsSummary: [QuestionsSummary] = QuestionsSummary.placeholders
    @Published var questionsFilter: Set<QuestionsFilter> = []
    @Published var loadingSections: Set<QuestionsLoadingSection> = []
    @Published var showLoadMore: Bool = false

    /// Private properties
    private var subscriptions = Set<AnyCancellable>()
    private var proxy: ViewManagerProxy
    
    /// Public properties
    var cachedQuestions: [QuestionsSummary] = []

    /// Subjects properties
    var emptyQuestionsSubject = PassthroughSubject<Void, Never>()
    var fetchTagsSubject = PassthroughSubject<AppSection, Never>()
    var fetchQuestionsSubject = CurrentValueSubject<AppSection, Never>(.questions)
    
    init(enableMock: Bool = false) {
        proxy = ViewManagerProxy(api: .init(enableMock: enableMock))
        bindFetchTags()
        bindFetchQuestions()
        bindEmptyQuestions()
    }
    
    private func bindEmptyQuestions() {
        emptyQuestionsSubject
            .sink { [weak self] _ in
                self?.tags.forEach { $0.isFavorite = false }
                self?.fetchQuestionsSubject.send(AppSection.questions)
            }.store(in: &subscriptions)
    }
}

// MARK: - Posts-related bindings
extension QuestionsViewManager {
    private func bindFetchTags() {
        proxy.fetchTags()
            .map { [weak self] _ -> AnyPublisher<[TagSummary], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.proxy.fetchTags()
            }
            .switchToLatest()
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.loadingSections.insert(.tags)
            }, receiveOutput: { [weak self] _ in
                self?.loadingSections.remove(.tags)
            })
            .assign(to: \.tags, on: self)
            .store(in: &subscriptions)
    }
    
    private func bindFetchQuestions() {
        fetchQuestionsSubject
            .dropFirst()
            .handleEvents(receiveOutput: { [weak self] output in
                guard case let .questions(subsection, action) = output else {
                    return
                }
                
                self?.loadingSections.insert(.questions)
                
                switch subsection {
                case .tag(let tag) where action == nil:
                    self?.tags.first(where: { $0.name == tag.name })?.isFavorite.toggle()
                case .search:
                    self?.tags.forEach { $0.isFavorite = false }
                default:
                    break
                }
            })
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .map { [self] section -> AnyPublisher<[QuestionsSummary], Never> in
                guard case let .questions(subsection, action) = section else {
                    fatalError()
                }
                
                switch subsection {
                case .search(let keywords):
                    let outputEvent: (Search) -> Void = { [weak self] in
                        self?.showLoadMore = $0.hasMore
                    }
                    
                    return proxy.fetchQuestionsByKeywords(keywords: keywords,
                                                          action: action,
                                                          outputEvent: outputEvent)
                case let .trending(trending):
                    let outputEvent: (Questions) -> Void = { [weak self] in
                        self?.showLoadMore = $0.hasMore && $0.quotaRemaining > 0
                    }
                    
                    return proxy.fetchQuestionsWithFilters(tags: [],
                                                           trending: trending,
                                                           action: action,
                                                           outputEvent: outputEvent)
                case .tag:
                    let outputEvent: (Questions) -> Void = { [weak self] in
                        self?.showLoadMore = $0.hasMore && $0.quotaRemaining > 0
                    }
                    
                    return proxy.fetchQuestionsWithFilters(tags: tags.filter(\.isFavorite).map(\.name),
                                                           trending: .votes,
                                                           action: action,
                                                           outputEvent: outputEvent)
                }
            }
            .switchToLatest()
            .assign(to: \.questionsSummary, on: self)
            .store(in: &subscriptions)
    }
}

extension QuestionsViewManager {
    func updateQuestionsFilter(_ filter: QuestionsFilter) {
        if questionsFilter.contains(filter) {
            questionsFilter.remove(filter)
        } else {
            questionsFilter.insert(filter)
        }
        
        let filteredQuestions = questionsFilter.isEmpty ?
            cachedQuestions:
            cachedQuestions.filtered(by: questionsFilter)
        
        questionsSummary = filteredQuestions.isEmpty ? QuestionsSummary.empty: filteredQuestions
    }
}
