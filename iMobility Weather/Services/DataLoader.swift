//
//  DataLoader.swift
//  iMobility Weather
//
//  Created by worker on 17/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import RxSwift
import RxSwiftExt

import Alamofire
import RxAlamofire

final class DataLoader {
    
    private static let apiKey: String = "9221b35402af6cf05d08413bad8a5a26"
    
    enum InitError: Swift.Error {
        
        case invalidBase
        
    }
    
    enum LoadingError: Swift.Error {
        
        case network
        case noConnection
        case mapping
        
    }
    
    let baseURL: URL
    let engine: NetworkEngine
    
    // MARK: - Init
    init(base: String,
         engine: NetworkEngine) throws {
        guard let url = URL(string: base) else {
            throw Error(with: InitError.invalidBase)
        }
        self.baseURL = url
        self.engine = engine
    }
   
}

extension DataLoader {
    
    // MARK: - Private
    private func _constructRequest(with relativePath: String,
                                   attributes queryAttributes: [String: String]) throws -> Request {
        var attributes = ["appid": type(of: self).apiKey,
                          "units": "metric"]
        queryAttributes.forEach({ (key, value) in
            attributes.updateValue(value, forKey: key)
        })
        return try Request(base: self.baseURL,
                           relativePath: relativePath,
                           queryItems: attributes.map({ (key, value) -> URLQueryItem in
                            return URLQueryItem(name: key, value: value)
                           }))
    }
    
}

// MARK: - Load
// MARK: Weather
extension DataLoader {
    
    func loadWeather(for name: String) -> Observable<Model.Service.Weather> {
        do {
            let request = try self._constructRequest(with: "/weather",
                                                     attributes: ["q": name])
            return self._load(request: request)
        }
        catch {
            return Observable.error(error)
        }
    }
    
    func loadWeather(for id: Int) -> Observable<Model.Service.Weather> {
        do {
            let request = try self._constructRequest(with: "/weather",
                                                     attributes: ["id": "\(id)"])
            return self._load(request: request)
        }
        catch {
            return Observable.error(error)
        }
    }
    
    func loadWeathers(for ids: [Int]) -> Observable<[Model.Service.Weather]> {
        do {
            let ids = ids
                .map({ (id) -> String in
                    return String(id)
                })
                .joined(separator: ",")
            let request = try self._constructRequest(with: "/group",
                                                     attributes: ["id": ids])
            return self._load(request: request)
                .map({ (data: Model.Service.Weather.List) -> [Model.Service.Weather] in
                    return data.list
                })
                .share(replay: 1,
                       scope: .forever)
        }
        catch {
            return Observable.error(error)
        }
    }
    
}

// MARK: Forecast
extension DataLoader {
    
    func loadForecasts(for id: Int) -> Observable<[Model.Service.Forecast]> {
        do {
            let request = try self._constructRequest(with: "/forecast",
                                                     attributes: ["id": "\(id)"])
            return self._load(request: request)
                .map({ (data: Model.Service.Forecast.List) -> [Model.Service.Forecast] in
                    return data.list
                })
                .share(replay: 1,
                       scope: .forever)
        }
        catch {
            return Observable.error(error)
        }
    }
    
}

extension DataLoader {
    
    private func _load<ObjectType>(request: Request) -> Observable<ObjectType> where ObjectType: Decodable {
        return self.engine
            .perform(request: request)
            //.debug("Received data:")
            .catchError({ (error) -> Observable<Data> in
                guard let urlError = error as? URLError,
                    [URLError.networkConnectionLost,
                     URLError.timedOut].contains(urlError.code) else {
                        return Observable.error(Error(with: LoadingError.network, underlyingError: error))
                }
                return Observable.error(Error(with: LoadingError.noConnection, underlyingError: error))
            })
            .map({ (data) -> ObjectType in
                return try JSONDecoder().decode(ObjectType.self,
                                                from: data)
            })
            .catchError({ (error) -> Observable<ObjectType> in
                guard error is DecodingError else {
                    return Observable.error(error)
                }
                return Observable.error(Error(with: LoadingError.mapping,
                                              underlyingError: error))
            })
            //.debug("Received object:")
            .share(replay: 1,
                   scope: .forever)
    }
    
}

extension DataLoader.InitError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .invalidBase:
            return "An instance couldn't be constructed due to invalid base URL string representation. Please contact support."
        }
    }
    
}

extension DataLoader.LoadingError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .network:
            return "The operation couldn’t be completed due to complication(s) with the network. Please check your connection."
        case .noConnection:
            return "The operation couldn’t be completed due to there is no internet connection. Please check your connection."
        case .mapping:
            return "The operation couldn’t be completed due to error(s) with mapping. Please contact support."
        }
    }
    
}
