//
//  ListViewModel.swift
//  iMobility Weather
//
//  Created by worker on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import RxSwift
import Action

protocol ListDataLoader {
    
    typealias ServiceModelType = Model.Service.Weather
    
    func loadWeathers(for ids: [Int]) -> Observable<[ServiceModelType]>
    
}

extension DataLoader: ListDataLoader { }

protocol ListDataProvider {
    
    typealias ServiceModelType = Model.Service.Weather
    typealias ModelType = Model.Content.Weather
    
    var holdWeathersAction: Action<[ServiceModelType], [ModelType]> { get }
    func weathers() -> Observable<[ModelType]>
    
}

extension DataProvider: ListDataProvider { }

protocol ListViewModelProtocol {
    
    typealias ServiceModelType = Model.Service.Weather
    typealias ModelType = Model.Content.Weather
    
    var data: Observable<[ListSection]> { get }
    var error: Observable<Swift.Error> { get }
    var isLoading: Observable<Bool> { get }
    
    var fetchAction: Action<Void, [ServiceModelType]> { get }
    
    init(dataLoader: ListDataLoader,
         dataProvider: ListDataProvider,
         predefinedCitiesIds: [Int])
    
}

final class ListViewModel: ListViewModelProtocol {
    
    let dataLoader: ListDataLoader
    let dataProvider: ListDataProvider
    
    private let _citiesIds: [Int]
    
    private let _disposeBag = DisposeBag()
    
    var data: Observable<[ListSection]>
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
    
    private(set) lazy var fetchAction: Action<Void, [ServiceModelType]> = self._createFetchAction()
    
    init(dataLoader: ListDataLoader,
         dataProvider: ListDataProvider,
         predefinedCitiesIds: [Int]) {
        self.dataLoader = dataLoader
        self.dataProvider = dataProvider
        
        self._citiesIds = predefinedCitiesIds
        
        self.data = dataProvider.weathers()
            .map({ (data) -> [ListSection] in
                return [ListSection(items: data)]
            })
            .observeOn(MainScheduler.asyncInstance)
        
        self.fetchAction
            .elements
            .bind(to: dataProvider.holdWeathersAction)
            .disposed(by: self._disposeBag)
    }
    
}

// MARK: - Create
extension ListViewModel {
    
    private func _createFetchAction() -> Action<Void, [ServiceModelType]> {
        return Action { [unowned self] () -> Observable<[ServiceModelType]> in
            return self.dataLoader.loadWeathers(for: self._citiesIds)
        }
    }
    
}
