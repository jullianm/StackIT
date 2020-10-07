//
//  Publisher.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import Foundation
import Combine

extension Publisher where Output == [QuestionsSummary], Failure == Never {
    func assign(to keyPath: ReferenceWritableKeyPath<QuestionsViewManager, Self.Output>,
                on object: QuestionsViewManager) -> AnyCancellable {
        debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { output in
                guard case let .questions(_, status) = object.fetchQuestionsSubject.value else { return }
                
                object.loadingSections.remove(.questions)
                
                guard output.count > 0 else {
                    object.questionsSummary = QuestionsSummary.empty
                    return
                }
                
                switch status {
                case .paging:
                    object.questionsSummary.append(contentsOf: output)
                    object.cachedQuestions.append(contentsOf: output)
                default:
                    object.questionsSummary = output
                    object.cachedQuestions = output
                }
            }
    }
}

extension Publisher where Output == [AnswersSummary], Failure == Never {
    func assign(to keyPath: ReferenceWritableKeyPath<AnswersViewManager, Self.Output>,
                on object: AnswersViewManager) -> AnyCancellable {
        debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { output in
                guard case let .answers(_, status) = object.fetchAnswersSubject.value else { return }
                
                object.loadingSections.remove(.answers)
                
                guard output.count > 0 else {
                    object.answersSummary = AnswersSummary.empty
                    return
                }
                
                switch status {
                case .paging:
                    object.answersSummary.append(contentsOf: output)
                default:
                    object.answersSummary = output
                }
            }
    }
}
