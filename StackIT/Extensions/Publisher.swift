//
//  Publisher.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import Foundation
import Combine

extension Publisher where Output == [QuestionsSummary], Failure == Never {
    func assign(to keyPath: ReferenceWritableKeyPath<ViewManager, Self.Output>,
                on object: ViewManager) -> AnyCancellable {
            sink { output in
                guard case let .questions(_, status) = object.fetchQuestionsSubject.value else { return }
                
                object.loadingSections = []
                
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
