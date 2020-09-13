//
//  Endpoint.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import Foundation

enum Endpoint {
    case questions(subendpoint: QuestionsEndpoint)
    case answers(subendpoint: AnswersEndpoint)
    case comments(subendpoint: CommentsEndpoint)
    case tags
    case user(token: String, key: String)
    case posts(token: String, key: String)
    case inbox(token: String, key: String)
    case timeline(token: String, key: String)
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/\(path)"
        components.queryItems = queryItems
        
        return components.url
    }
    
    var sectionStatus: SectionStatus {
        switch self {
        case .questions(let subendpoint):
            return subendpoint.status
        default:
            return .active
        }
    }
    
    var urlRequest: URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/\(path)"
        components.queryItems = queryItems
        
        guard let url = url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = components.query?.data(using: .utf8)
        
        return request
    }
    
    var cacheID: String {
        switch self {
        case .questions(let subendpoint):
            switch subendpoint {
            case let .questionsByFilters(tags, trending, status):
                return tags.map(\.name).joined(separator: ";") + "&" + trending.rawValue + status.pageCount.string()
            case .questionsByIds(let ids):
                return ids
            case .questionsByKeywords(let keywords, _):
                return keywords
            }
        case let .answers(subendpoint):
            switch subendpoint {
            case .answersByQuestionId(let questionId):
                return subendpoint.path + questionId
            case .answersByIds(let ids):
                return subendpoint.path + ids
            }
        case let .comments(subendpoint):
            switch subendpoint {
            case .commentsByAnswersIds(let ids),
                 .commentsByIds(let ids),
                 .commentsByQuestionsIds(let ids):
                return subendpoint.path + ids
            }
        default:
            return .init()
        }
    }
    
    private var host: String {
        return "api.stackexchange.com"
    }
        
    private var path: String {
        switch self {
        case .tags:
            return "2.2/tags"
        case .questions(let subendpoint):
            return subendpoint.path
        case .user:
            return "/2.2/me"
        case .posts:
            return "/2.2/me/posts"
        case .inbox:
            return "/2.2/me/inbox"
        case .comments(let subendpoint):
            return subendpoint.path
        case .answers(let subendpoint):
            return subendpoint.path
        case .timeline:
            return "/2.2/me/timeline"
        }
    }
    
    var headers: [String: String] {
        return .init()
    }
    
    var method: String {
        return "GET"
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .tags:
            return [
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "popular"),
                .init(name: "site", value: "stackoverflow")
            ]
        case let .user(token, key):
            return [
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "reputation"),
                .init(name: "site", value: "stackoverflow"),
                .init(name: "access_token", value: token),
                .init(name: "key", value: key)
            ]
        case .posts(let token, let key):
            return [
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "activity"),
                .init(name: "site", value: "stackoverflow"),
                .init(name: "access_token", value: token),
                .init(name: "key", value: key)
            ]
        case .inbox(token: let token, key: let key):
            return [
                .init(name: "site", value: "stackoverflow"),
                .init(name: "access_token", value: token),
                .init(name: "key", value: key),
                .init(name: "filter", value: "withbody")
            ]
        case .questions(let subendpoint):
            return subendpoint.queryItems
        case .answers(let subendpoint):
            return subendpoint.queryItems
        case .comments(let subendpoint):
            return subendpoint.queryItems
        case .timeline(token: let token, key: let key):
            return [
                .init(name: "site", value: "stackoverflow"),
                .init(name: "access_token", value: token),
                .init(name: "key", value: key)
            ]
        }
    }
    
    var mockData: Data {
        switch self {
        case .questions(let subendpoint):
            return subendpoint.mockData
        case .tags:
            return Bundle.main.data(from: "Tags.json")
        case .answers(let subendpoint):
            return subendpoint.mockData
        case .comments(let subendpoint):
            return subendpoint.mockData
        case .user:
            return Bundle.main.data(from: "User.json")
        case .posts:
            return Bundle.main.data(from: "Posts.json")
        case .inbox:
            return Bundle.main.data(from: "Inbox.json")
        case .timeline:
            return Bundle.main.data(from: "Activity.json")
        }
    }
}

enum QuestionsEndpoint {
    case questionsByFilters(tags: [Tag], trending: Trending, status: SectionStatus)
    case questionsByIds(_ ids: String)
    case questionsByKeywords(_ keywords: String, status: SectionStatus)
    
    var status: SectionStatus {
        switch self {
        case .questionsByFilters(_, _, let status):
            return status
        default:
            return .active
        }
    }
    
    var path: String {
        switch self {
        case .questionsByFilters:
            return "2.2/questions"
        case .questionsByKeywords:
            return "2.2/search/excerpts"
        case .questionsByIds(let ids):
            return "2.2/questions/\(ids)"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case let .questionsByFilters(tags, trending, status):
            var items: [URLQueryItem] = [
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: trending.rawValue),
                .init(name: "site", value: "stackoverflow"),
                .init(name: "filter", value: "withbody"),
                .init(name: "page", value: status.pageCount.string())
            ]
            if !tags.isEmpty {
                items.append(.init(name: "tagged", value: tags.map(\.name).joined(separator: ";")))
            }
            
            return items
        case let .questionsByKeywords(keywords, _):
            return [
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "relevance"),
                .init(name: "site", value: "stackoverflow"),
                .init(name: "q", value: keywords)
            ]
        case .questionsByIds:
            return [
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "activity"),
                .init(name: "site", value: "stackoverflow"),
                .init(name: "filter", value: "withbody")
            ]
        }
    }
    
    var mockData: Data {
        switch self {
        case .questionsByFilters, .questionsByIds:
            return Bundle.main.data(from: "Questions.json")
        case .questionsByKeywords:
            return Bundle.main.data(from: "Search.json")
        }
    }
}

enum AnswersEndpoint {
    case answersByIds(_ ids: String)
    case answersByQuestionId(_ questionId: String)
    
    var path: String {
        switch self {
        case let .answersByQuestionId(questionId):
            return "2.2/questions/\(questionId)/answers"
        case .answersByIds(let ids):
            return "2.2/answers/\(ids)"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .answersByQuestionId:
            return [
                .init(name: "order", value: "desc"),
                .init(name: "site", value: "stackoverflow"),
                .init(name: "filter", value: "withbody")
            ]
        case .answersByIds:
            return [
                .init(name: "site", value: "stackoverflow"),
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "activity"),
                .init(name: "filter", value: "withbody")
            ]
        }
    }
    
    var mockData: Data {
        switch self {
        case .answersByQuestionId, .answersByIds:
            return Bundle.main.data(from: "Answers.json")
        }
    }
}

enum CommentsEndpoint {
    case commentsByIds(_ ids: String)
    case commentsByAnswersIds(_ answersId: String)
    case commentsByQuestionsIds(_ questionsId: String)
    
    var path: String {
        switch self {
        case .commentsByAnswersIds(let answersId):
            return "2.2/answers/\(answersId)/comments"
        case .commentsByIds(let ids):
            return "/2.2/comments/\(ids)"
        case .commentsByQuestionsIds(let questionsId):
            return "2.2/questions/\(questionsId)/comments"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .commentsByAnswersIds:
            return [
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "creation"),
                .init(name: "site", value: "stackoverflow"),
                .init(name: "filter", value: "withbody")
            ]
        case .commentsByIds:
            return [
                .init(name: "site", value: "stackoverflow"),
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "creation"),
                .init(name: "filter", value: "withbody")
            ]
        case .commentsByQuestionsIds:
            return [
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "creation"),
                .init(name: "site", value: "stackoverflow"),
                .init(name: "filter", value: "withbody")
            ]
        }
    }
    
    var mockData: Data {
        switch self {
        case .commentsByIds, .commentsByQuestionsIds, .commentsByAnswersIds:
            return Bundle.main.data(from: "Comments.json")
        }
    }
}
