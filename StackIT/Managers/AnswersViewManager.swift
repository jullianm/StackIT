//
//  AnswersViewManager.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-29.
//

import Combine
import Foundation
import StackAPI

class AnswersViewManager: ObservableObject {
    /// Published properties
    var selectedQuestion: QuestionsSummary?
    @Published var answersSummary: [AnswersSummary] = []
    @Published var commentsSummary: [CommentsSummary] = []
    @Published var loadingSections: Set<AnswersLoadingSection> = []
    @Published var showLoadMore: Bool = false

    /// Private properties
    private var subscriptions = Set<AnyCancellable>()
    private var proxy: ViewManagerProxy

    /// Subjects properties
    var fetchAnswersSubject = CurrentValueSubject<AppSection?, Never>(nil)
    var fetchCommentsSubject = PassthroughSubject<AppSection, Never>()
    var resetSubject = PassthroughSubject<Void, Never>()
    
    init(enableMock: Bool = false) {
        proxy = ViewManagerProxy(api: .init(enableMock: enableMock))
        bindFetchAnswers()
        bindResetSubject()
    }
}

// MARK: - Posts-related bindings
extension AnswersViewManager {
    private func bindResetSubject() {
        resetSubject
            .sink { [weak self] _ in
                self?.answersSummary = []
            }.store(in: &subscriptions)
    }
    
    private func bindFetchAnswers() {
        fetchAnswersSubject
            .handleEvents(receiveOutput: { [weak self] output in
                guard case .answers(let question, let action) = output else { return }
                
                if case .none = action { /// not paging or refreshing
                    self?.answersSummary = []
                }
                self?.selectedQuestion = question
                self?.loadingSections.insert(.answers)
            })
            .map { [self] section -> AnyPublisher<[AnswersSummary], Error> in
                guard case let .answers(question, action) = section else {
                    return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                
                let outputEvent: (Answers) -> Void = { [weak self] in
                    self?.showLoadMore = $0.hasMore
                }
                
                return proxy.fetchAnswersByQuestionId(question.questionId,
                                                      outputEvent: outputEvent,
                                                      action: action)
            }
            .switchToLatest()
            .map { answers in
                var values = answers
                values.enumerated().forEach { index, value in
                    values[index].messageDetails = MessageExtractor.sharedInstance.parse(html: value.body)
                }
                
                return values
            }
            .replaceError(with: [])
            .assign(to: \.answersSummary, on: self)
            .store(in: &subscriptions)
    }
}

