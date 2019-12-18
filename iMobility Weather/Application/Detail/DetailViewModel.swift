//
//  DetailViewModel.swift
//  iMobility Weather
//
//  Created by Milan Horvatovic on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import RxSwift
import Action

protocol DetailDataLoader {
    
    typealias WeatherServiceModelType = Model.Service.Weather
    typealias ForecastServiceModelType = Model.Service.Forecast
    
    func loadWeather(for id: Int) -> Observable<WeatherServiceModelType>
    func loadForecasts(for id: Int) -> Observable<[ForecastServiceModelType]>
    
}

extension DataLoader: DetailDataLoader { }

protocol DetailDataProvider {
    
    typealias WeatherServiceModelType = Model.Service.Weather
    typealias WeatherModelType = Model.Content.Weather
    typealias ForecastServiceModelType = Model.Service.Forecast
    typealias ForecastModelType = Model.Content.Forecast
    
    typealias ForecastsActionType = (id: Int, forecasts: [ForecastServiceModelType])
    typealias ForecastsType = [Int: [ForecastModelType]]
    
    var holdWeatherAction: Action<WeatherServiceModelType, WeatherModelType> { get }
    var holdForecastsAction: Action<ForecastsActionType, ForecastsType> { get }
    
    func weather(for weather: WeatherModelType) -> Observable<WeatherModelType?>
    func forecasts(for weather: WeatherModelType) -> Observable<[ForecastModelType]>
    
}

extension DataProvider: DetailDataProvider { }

protocol DetailViewModelProtocol {
    
    typealias WeatherServiceModelType = Model.Service.Weather
    typealias WeatherModelType = Model.Content.Weather
    typealias ForecastServiceModelType = Model.Service.Forecast
    typealias ForecastModelType = Model.Content.Forecast
    
    var weatherData: Observable<WeatherModelType> { get }
    var forecastData: Observable<[DetailListSection]> { get }
    var error: Observable<Swift.Error> { get }
    var isLoading: Observable<Bool> { get }
    
    var fetchAction: Action<Void, Void> { get }
    var fetchWeatherAction: Action<Void, WeatherServiceModelType> { get }
    var fetchForecastAction: Action<Void, [ForecastServiceModelType]> { get }
    
    init(dataLoader: DetailDataLoader,
         dataProvider: DetailDataProvider,
         weather: Model.Content.Weather)
    
}

final class DetailViewModel: DetailViewModelProtocol {
    
    let dataLoader: DetailDataLoader
    let dataProvider: DetailDataProvider
    
    private let _disposeBag = DisposeBag()
    
    private let _weather: WeatherModelType
    
    var weatherData: Observable<WeatherModelType>
    var forecastData: Observable<[DetailListSection]>
    var error: Observable<Swift.Error> {
        return self.fetchAction.underlyingError
            .observeOn(MainScheduler.asyncInstance)
            .share(replay: 1,
                   scope: .forever)
    }
    var isLoading: Observable<Bool> {
        return self.fetchAction.executing
            .observeOn(MainScheduler.asyncInstance)
            .share(replay: 1,
                   scope: .forever)
    }
    
    private(set) lazy var fetchAction: Action<Void, Void> = self._createFetchAction()
    private(set) lazy var fetchWeatherAction: Action<Void, WeatherServiceModelType> = self._createFetchWeatherAction()
    private(set) lazy var fetchForecastAction: Action<Void, [ForecastServiceModelType]> = self._createFetchForecastAction()
    
    init(dataLoader: DetailDataLoader,
         dataProvider: DetailDataProvider,
         weather: Model.Content.Weather) {
        self.dataLoader = dataLoader
        self.dataProvider = dataProvider
        
        self._weather = weather
        
        self.weatherData = dataProvider.weather(for: weather)
            .filterNil()
            .observeOn(MainScheduler.asyncInstance)
        self.forecastData = dataProvider.forecasts(for: weather)
            .map({ (data) -> [DetailListSection] in
                return data
                    .map({ (data) -> [Int: ForecastModelType] in
                        return [(data.id / 86400): data]
                    })
                    .reduce([:], { (result, part) -> [Int: [ForecastModelType]] in
                        var result = result
                        for (key, element) in part {
                            var objects = result[key] ?? []
                            objects.append(element)
                            result[key] = objects
                        }
                        return result
                    })
                    .map({ (data) -> DetailListSection in
                        return DetailListSection(header: "\(data.key)", items: data.value.sorted(by: SortDescriptor { $0.id < $1.id }))
                    })
                    .sorted(by: SortDescriptor { $0.identity < $1.identity })
            })
            .observeOn(MainScheduler.asyncInstance)
        
        let fetchAction = self.fetchAction
            .elements
            .share(replay: 1,
                   scope: .forever)
        
        fetchAction
            .bind(to: self.fetchWeatherAction)
            .disposed(by: self._disposeBag)
        fetchAction
            .bind(to: self.fetchForecastAction)
            .disposed(by: self._disposeBag)
        
        self.fetchWeatherAction
            .elements
            .bind(to: dataProvider.holdWeatherAction)
            .disposed(by: self._disposeBag)
        
        self.fetchForecastAction
            .elements
            .map({ [unowned self] (forecasts) -> (Int, [ForecastServiceModelType]) in
                return (self._weather.id, forecasts)
            })
            .bind(to: dataProvider.holdForecastsAction)
            .disposed(by: self._disposeBag)
    }
    
}

// MARK: - Create
extension DetailViewModel {
    
    private func _createFetchAction() -> Action<Void, Void> {
        return Action { (value) -> Observable<Void> in
            return Observable.just(value)
        }
    }
    
    private func _createFetchWeatherAction() -> Action<Void, WeatherServiceModelType> {
        return Action { [unowned self] () -> Observable<WeatherServiceModelType> in
            return self.dataLoader.loadWeather(for: self._weather.id)
        }
    }
    
    private func _createFetchForecastAction() -> Action<Void, [ForecastServiceModelType]> {
        return Action { [unowned self] () -> Observable<[ForecastServiceModelType]> in
            return self.dataLoader.loadForecasts(for: self._weather.id)
        }
    }
    
}
