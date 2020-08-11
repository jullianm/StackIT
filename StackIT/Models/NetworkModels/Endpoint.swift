//
//  Endpoint.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import Foundation

enum Endpoint {
    case filteredQuestions(tags: [Tag], trending: Trending, page: Int)
    case questions(ids: String)
    case answers(ids: String)
    case comments(ids: String)
    case answersForQuestion(questionId: String)
    case commentsForAnswers(answersId: String)
    case commentsForQuestions(questionsId: String)
    case tags
    case search(keywords: String)
    case user(token: String, key: String)
    case posts(token: String, key: String)
    case inbox(token: String, key: String)
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/\(path)"
        components.queryItems = queryItems
        
        return components.url
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
        case let .filteredQuestions(tags: tags, trending: trending, page: page):
            return tags.map(\.name).joined(separator: ";") + "&" + trending.rawValue + page.string()
        case let .answers(questionId):
            return questionId
        default:
            return .init()
        }
    }
    
    private var host: String {
        return "api.stackexchange.com"
    }
        
    private var path: String {
        switch self {
        case .filteredQuestions:
            return "2.2/questions"
        case .tags:
            return "2.2/tags"
        case let .answersForQuestion(questionId):
            return "2.2/questions/\(questionId)/answers"
        case .search:
            return "2.2/search/excerpts"
        case .questions(let ids):
            return "2.2/questions/\(ids)"
        case .commentsForAnswers(let answersId):
            return "2.2/answers/\(answersId)/comments"
        case .user:
            return "/2.2/me"
        case .posts:
            return "/2.2/me/posts"
        case .inbox:
            return "/2.2/me/inbox"
        case .comments(let ids):
            return "/2.2/comments/\(ids)"
        case .answers(let ids):
            return "2.2/answers/\(ids)"
        case .commentsForQuestions(let questionsId):
            return "2.2/questions/\(questionsId)/comments"
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
        case let .filteredQuestions(tags, trending, page):
            var items: [URLQueryItem] = [
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: trending.rawValue),
                .init(name: "site", value: "stackoverflow"),
                .init(name: "filter", value: "withbody"),
                .init(name: "page", value: page.string())
            ]
            if !tags.isEmpty {
                items.append(.init(name: "tagged", value: tags.map(\.name).joined(separator: ";")))
            }
            
            return items
        case .tags:
            return [
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "popular"),
                .init(name: "site", value: "stackoverflow")
            ]
        case .answersForQuestion:
            return [
                .init(name: "order", value: "desc"),
                .init(name: "site", value: "stackoverflow"),
                .init(name: "filter", value: "withbody")
            ]
        case let .search(keywords):
            return [
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "relevance"),
                .init(name: "site", value: "stackoverflow"),
                .init(name: "q", value: keywords)
            ]
        case .commentsForAnswers:
            return [
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "creation"),
                .init(name: "site", value: "stackoverflow"),
                .init(name: "filter", value: "withbody")
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
        case .questions:
            return [
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "activity"),
                .init(name: "site", value: "stackoverflow"),
                .init(name: "filter", value: "withbody")
            ]
        case .answers:
            return [
                .init(name: "site", value: "stackoverflow"),
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "activity"),
                .init(name: "filter", value: "withbody")
            ]
        case .comments:
            return [
                .init(name: "site", value: "stackoverflow"),
                .init(name: "order", value: "desc"),
                .init(name: "sort", value: "creation"),
                .init(name: "filter", value: "withbody")
            ]
        case .commentsForQuestions:
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
        case .filteredQuestions, .questions:
            return Bundle.main.data(from: "Questions.json")
        case .tags:
            return Bundle.main.data(from: "Tags.json")
        case .answersForQuestion, .answers:
            return Bundle.main.data(from: "Answers.json")
        case .search:
            return Bundle.main.data(from: "Search.json")
        case .commentsForAnswers, .commentsForQuestions, .comments:
            return Bundle.main.data(from: "Comments.json")
        case .user:
            return Bundle.main.data(from: "User.json")
        case .posts:
            return Bundle.main.data(from: "Posts.json")
        case .inbox:
            return Bundle.main.data(from: "Inbox.json")
        }
    }
}
