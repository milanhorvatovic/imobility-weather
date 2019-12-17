//
//  NetworkEngineMock.swift
//  iMobility WeatherTests
//
//  Created by worker on 17/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import XCTest
@testable import iMobility_Weather

import RxSwift

final class NetworkEngineMock {
    
    static func realMock() -> NetworkEngine {
        return URLSession(configuration: URLSessionConfiguration.default)
    }
    
}

extension NetworkEngineMock {
    
    
    
}
