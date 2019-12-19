//
//  NetworkEngine.swift
//  iMobility Weather
//
//  Created by worker on 17/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import Alamofire
import RxAlamofire

struct Request {
    
    enum InitError: Swift.Error {
        
        case base
        case relative
        
    }
    
    fileprivate enum Method {
    
        case get
        
    }
    
    let url: URL
    fileprivate let method: Method
    
}

extension Request {
    
    private init(urlComponents: URLComponents,
                 relativePath: String,
                 queryItems: [URLQueryItem]? = nil) throws {
        var urlComponents = urlComponents
        let slashSet = CharacterSet(charactersIn: "/")
        let path = [urlComponents.path.trimmingCharacters(in: slashSet),
                    relativePath.trimmingCharacters(in: slashSet)]
            .joined(separator: "/")
        urlComponents.path = "/" + path
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw InitError.relative
        }
        self.init(url: url, method: .get)
    }
    
    init(base: String,
         relativePath: String,
         queryItems: [URLQueryItem]? = nil) throws {
        guard let urlComponents = URLComponents(string: base) else {
            throw InitError.base
        }
        try self.init(urlComponents: urlComponents,
                      relativePath: relativePath)
    }
    
    init(base: URL,
         relativePath: String,
         queryItems: [URLQueryItem]? = nil) throws {
        guard let urlComponents = URLComponents(url: base,
                                                resolvingAgainstBaseURL: true)
            else {
            throw InitError.base
        }
        try self.init(urlComponents: urlComponents,
                      relativePath: relativePath,
                      queryItems: queryItems)
    }
    
}

extension Request.Method {

    var alamofireMethod: HTTPMethod {
        switch self {
        case .get:
            return .get
        }
    }

}

protocol NetworkEngine {
    
    func perform(request: Request) -> Observable<Data>
    
    func cancelAllRequets()
    
}

extension SessionManager: NetworkEngine {

    func perform(request: Request) -> Observable<Data> {
        return RxAlamofire.requestData(request.method.alamofireMethod,
                                       request.url)
            .map({ (_, data) -> Data in
                return data
            })
    }

    func cancelAllRequets() {
        self.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            let cancel: (URLSessionTask) -> Void = { (task) in
                task.cancel()
            }
            dataTasks.forEach(cancel)
            uploadTasks.forEach(cancel)
            downloadTasks.forEach(cancel)
        }
    }

}

extension URLSession: NetworkEngine {
    
    func perform(request: Request) -> Observable<Data> {
        let urlRequest = URLRequest(url: request.url)
        return self.rx.response(request: urlRequest)
            .filter({ (response, data) -> Bool in
                return 200..<399 ~= response.statusCode
            })
            .map({ (_, data) -> Data in
                return data
            })
    }
    
    func cancelAllRequets() {
        self.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            let cancel: (URLSessionTask) -> Void = { (task) in
                task.cancel()
            }
            dataTasks.forEach(cancel)
            uploadTasks.forEach(cancel)
            downloadTasks.forEach(cancel)
        }
    }
    
}
