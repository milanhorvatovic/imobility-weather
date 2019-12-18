//
//  ObservableType+Action.swift
//  iMobility WeatherTests
//
//  Created by worker on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import RxSwift
import Action

public extension RxSwift.ObservableType {
    
    func bind<ValueType>(to action: Action<ValueType, ValueType>) -> Disposable where ValueType == Element {
        return self.bind(to: action.inputs)
    }
    
    func bind<ValueType, OutputValueType>(to action: Action<ValueType, OutputValueType>) -> Disposable where ValueType == Element {
        return self.bind(to: action.inputs)
    }
    
    func bind<ValueType, InputValueType, OutputValueType>(to action: Action<InputValueType, OutputValueType>, inputTransform: @escaping (ValueType) -> (InputValueType)) -> Disposable where ValueType == Element {
        return self
            .map({ (input: ValueType) -> InputValueType in
                return inputTransform(input)
            })
            .bind(to: action.inputs)
    }
    
}
