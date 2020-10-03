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
    var fetchAnswersSubject = PassthroughSubject<AppSection, Never>()
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
                guard case .answers(let question, _) = output else { return }
                
                self?.selectedQuestion = question
                self?.loadingSections.insert(.answers)
            })
            .map { [self] section -> AnyPublisher<[AnswersSummary], Never> in
                guard case let .answers(question, _) = section else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                return proxy.fetchAnswersByQuestionId(question.questionId)
            }
            .switchToLatest()
            .map { answers in
                var values = answers
                values.enumerated().forEach { index, value in
                    values[index].messageDetails = MessageExtractor.sharedInstance.parse(html: value.body)
                }
                
                return values
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.loadingSections.remove(.answers)
            })
            .replaceError(with: [])
            .assign(to: \.answersSummary, on: self)
            .store(in: &subscriptions)
    }
}

