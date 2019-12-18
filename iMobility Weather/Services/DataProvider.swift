//
//  DataProvider.swift
//  iMobility Weather
//
//  Created by worker on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import RxSwift
import Action

final class DataProvider {
    
    typealias WeatherType = Model.Content.Weather
    typealias ForecastsActionType = (id: Int, forecasts: [Model.Service.Forecast])
    typealias ForecastsType = [Int: [Model.Content.Forecast]]
    
    private let _disposeBag = DisposeBag()
    
    private let _weathers = BehaviorSubject<[WeatherType]>(value: [])
    private let _forecasts = BehaviorSubject<ForecastsType>(value: [:])
    
    private(set) lazy var holdWeatherAction = self._createHoldWeatherAction()
    private(set) lazy var holdWeathersAction = self._createHoldWeathersAction()
    private(set) lazy var holdForecastsAction = self._createHoldForecastAction()
    init() {
        self.holdWeatherAction.elements
            .withLatestFrom(self._weathers,
                            resultSelector: { (weather, weathers) -> [WeatherType] in
                                var weathers = weathers
                                if let index = weathers.enumerated().filter({ return $0.element.id == weather.id }).first?.offset {
                                    weathers.remove(at: index)
                                    weathers.insert(weather, at: index)
                                }
                                else {
                                    weathers.append(weather)
                                }
                                return weathers
            })
            .bind(to: self._weathers)
            .disposed(by: self._disposeBag)
        
        self.holdWeathersAction.elements
                .bind(to: self._weathers)
                .disposed(by: self._disposeBag)
        
        self.holdForecastsAction.elements
            .withLatestFrom(self._forecasts,
                            resultSelector: { (new, old) -> ForecastsType in
                                var result = old
                                for (key, value) in new {
                                    result.updateValue(value, forKey: key)
                                }
                                return result
            })
            .bind(to: self._forecasts)
            .disposed(by: self._disposeBag)
    }
    
}

// MARK: Create
extension DataProvider {
    
    private func _createHoldWeatherAction() -> Action<Model.Service.Weather, Model.Content.Weather> {
        return Action { (source) -> Observable<Model.Content.Weather> in
            return Observable.just(Model.Content.Weather(id: source.id,
                                                         service: source))
        }
    }
    
    private func _createHoldWeathersAction() -> Action<[Model.Service.Weather], [Model.Content.Weather]> {
        return Action { (source) -> Observable<[Model.Content.Weather]> in
            return Observable.just(source.map({ (weather) -> Model.Content.Weather in
                return Model.Content.Weather(id: weather.id,
                                             service: weather)
            }))
        }
    }
    
    private func _createHoldForecastAction() -> Action<ForecastsActionType, ForecastsType> {
        return Action { (source) -> Observable<ForecastsType> in
            return Observable.just([source.id: source.forecasts.map({ (forecast) -> Model.Content.Forecast in
                return Model.Content.Forecast(with: forecast)
            })])
        }
    }
    
}

// MARK: Provide
extension DataProvider {
    
    func weather(for weather: Model.Content.Weather) -> Observable<Model.Content.Weather?> {
        return self._weathers
            .map({ (weathers) -> Model.Content.Weather? in
                return weathers.filter(matching: Predicate { $0.id == weather.id }).first
            })
    }
    
    func weathers() -> Observable<[Model.Content.Weather]> {
        return self._weathers
            .map({ (weathers) -> [Model.Content.Weather] in
                return weathers.filter(matching: Predicate { $0.service != nil })
                    .sorted(by: SortDescriptor { $0.service!.name > $1.service!.name })
            })
            .distinctUntilChanged()
            .share(replay: 1,
                   scope: .forever)
    }
    
    func forecasts(for weather: Model.Content.Weather) -> Observable<[Model.Content.Forecast]> {
        return self._forecasts
            .map({ (map) -> [Model.Content.Forecast] in
                return map[weather.id] ?? []
            })
            .filter({ (forecasts) -> Bool in
                return !forecasts.isEmpty
            })
            .map({ (forecasts) -> [Model.Content.Forecast] in
                return forecasts.sorted(by: SortDescriptor { $0.service.date < $1.service.date })
            })
            .distinctUntilChanged()
            .share(replay: 1,
                   scope: .forever)
    }
    
}
