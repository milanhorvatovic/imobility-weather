//
//  DataLoaderTest.swift
//  iMobility WeatherTests
//
//  Created by worker on 17/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import XCTest
@testable import iMobility_Weather

import RxBlocking

class DataLoaderTests: XCTestCase {
    
    private typealias ExpectationWeather = (id: Int, name: String)
    private typealias SampleWeatherName = (name: String, expectation: ExpectationWeather)
    
}

// MARK: - Prepare
extension DataLoaderTests {
    
    private func _prepareRealLoader(with engine: NetworkEngine) throws -> DataLoader {
        return try DataLoaderMock.realMock(with: engine)
    }
    
    private func _prepareRealNetworkEngine() -> NetworkEngine {
        return NetworkEngineMock.realMock()
    }
    
}

// MARK: - Tests
extension DataLoaderTests {
    
    func test_weather_real_data() {
        do {
            let loader = try self._prepareRealLoader(with: self._prepareRealNetworkEngine())
            
            try [("san francisco", (3669881, "San Francisco")),
                 ("chicago", (4887398, "Chicago")),
                 ("new york", (5128581, "New York")),
                 ("london", (2643743, "London")),
                 ("vienna", (2761369, "Vienna")),]
                .forEach({ (sample) in
                    try self._try_weather_real(with: loader, sample: sample)
                })
            
            try ["abcd",
             "efgh",
             "ijkl",]
                .forEach({ (sample) in
                    try self._try_weather_real_failure(with: loader, sample: sample)
                })
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_forecast_real_data() {
        do {
            let loader = try self._prepareRealLoader(with: self._prepareRealNetworkEngine())
            
            try [3669881,
                 4887398,
                 5128581,
                 2643743,
                 2761369,]
                .forEach({ (sample) in
                    try self._try_forecast_real(with: loader, sample: sample)
                })
            
            try [462787489235,
                 320563848784,
                 934087509672,
                 238543960823,
                 859062342346,]
                .forEach({ (sample) in
                    try self._try_forecast_real_failure(with: loader, sample: sample)
                })
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }
    
}

// MARK: - Try
// MARK: Real data weather
extension DataLoaderTests {
    
    private func _try_weather_real(with loader: DataLoader,
                                   sample: SampleWeatherName) throws {
        let result = try loader.loadWeather(for: sample.name).toBlocking().first()
        XCTAssertNotNil(result)
        guard let object = result else {
            return
        }
        XCTAssertEqual(object.id, sample.expectation.id)
        XCTAssertEqual(object.name, sample.expectation.name)
    }
    
    private func _try_weather_real_failure(with loader: DataLoader,
                                   sample: String) throws {
        let result = try loader.loadWeather(for: sample).toBlocking().first()
        XCTAssertNil(result)
    }
    
}

// MARK: Real data forecast
extension DataLoaderTests {
    
    private func _try_forecast_real(with loader: DataLoader,
                                    sample: Int) throws {
        let result = try loader.loadForecasts(for: sample).toBlocking().first()
        XCTAssertNotNil(result)
        guard let object = result else {
            return
        }
        XCTAssertFalse(object.isEmpty)
    }
    
    private func _try_forecast_real_failure(with loader: DataLoader,
                                            sample: Int) throws {
        let result = try loader.loadForecasts(for: sample).toBlocking().first()
        XCTAssertNil(result)
    }
    
}
