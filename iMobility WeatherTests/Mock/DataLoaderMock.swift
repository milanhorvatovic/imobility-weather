//
//  DataLoaderMock.swift
//  iMobility WeatherTests
//
//  Created by worker on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import XCTest
@testable import iMobility_Weather

import RxSwift

final class DataLoaderMock {
    
    static func realMock(with engine: NetworkEngine) throws -> DataLoader {
        return try DataLoader(base: "https://api.openweathermap.org/data/2.5",
                              engine: engine)
    }
    
}
