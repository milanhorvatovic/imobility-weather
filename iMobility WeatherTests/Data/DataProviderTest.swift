//
//  DataProviderTest.swift
//  iMobility WeatherTests
//
//  Created by worker on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import XCTest
@testable import iMobility_Weather

import RxSwift

import RxBlocking

class DataProviderTests: XCTestCase {
    
    private var _disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        
        self._disposeBag = DisposeBag()
    }
    
    func test_weather_real_data() {
        do {
            let loader = try self._prepareRealLoader(with: self._prepareRealNetworkEngine())
            let provider = DataProvider()
            
            let correctIds = [3669881,
                       4887398,
                       5128581,
                       2643743,
                       2761369,]
            
            try self._try_weather_real(with: loader,
                                       provider: provider,
                                       samples: correctIds)
            
            let invalidIds = [462787489235,
                              320563848784,
                              934087509672,
                              238543960823,
                              859062342346,]
            try self._try_weather_real_failure(with: loader,
                                               provider: provider,
                                               samples: invalidIds)
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }
    
}

// MARK: - Prepare
extension DataProviderTests {
    
    private func _prepareRealLoader(with engine: NetworkEngine) throws -> DataLoader {
        return try DataLoaderMock.realMock(with: engine)
    }
    
    private func _prepareRealNetworkEngine() -> NetworkEngine {
        return NetworkEngineMock.realMock()
    }
    
}

// MARK: - Try
// MARK: Real data weather
extension DataProviderTests {
    
    private func _try_weather_real(with loader: DataLoader,
                                   provider: DataProvider,
                                   samples: [Int]) throws {
        loader.loadWeathers(for: samples)
            .bind(to: provider.holdWeathersAction)
            .disposed(by: self._disposeBag)
        
        let weathers = provider.weathers()
            .skip(1)
        
        weathers
            .debug("Weathers:")
            .subscribe()
            .disposed(by: self._disposeBag)
        
        let result = try weathers
            .toBlocking()
            .first()
        XCTAssertNotNil(result)
        guard let object = result else {
            return
        }
        XCTAssertFalse(object.isEmpty)
    }
    
    private func _try_weather_real_failure(with loader: DataLoader,
                                           provider: DataProvider,
                                           samples: [Int]) throws {
        loader.loadWeathers(for: samples)
            .bind(to: provider.holdWeathersAction)
            .disposed(by: self._disposeBag)
        
        let weathers = provider.weathers()
            .skip(1)
        
        weathers
            .debug("Weathers:")
            .subscribe()
            .disposed(by: self._disposeBag)
        /*
        let result = try weathers
            .toBlocking()
            .last()
        XCTAssertNil(result)
         */
    }
    
}
