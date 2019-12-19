//
//  ListModel.swift
//  iMobility Weather
//
//  Created by worker on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import RxDataSources

extension Model.Content.Weather: IdentifiableType {
    
    var identity: Int {
        return self.id
    }
    
}

struct ListSection {
    
    typealias Item = Model.Content.Weather
    
    var header: String = "Static cities"
    var items: [Item]
    
}

extension ListSection: AnimatableSectionModelType {
    
    var identity: String {
        return self.header
    }
    
    init(original: Self,
         items: [Self.Item]) {
        self = original
        self.items = items
    }
    
}
