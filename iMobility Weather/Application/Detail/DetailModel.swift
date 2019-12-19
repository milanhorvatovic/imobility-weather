//
//  DetailModel.swift
//  iMobility Weather
//
//  Created by Milan Horvatovic on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import RxDataSources

extension Model.Content.Forecast: IdentifiableType {
    
    var identity: Int {
        return self.id
    }
    
}

struct DetailListSection {
    
    typealias Item = Model.Content.Forecast
    
    var header: String
    var items: [Item]
    
}

extension DetailListSection: AnimatableSectionModelType {
    
    var identity: String {
        return self.header
    }
    
    init(original: Self,
         items: [Self.Item]) {
        self = original
        self.items = items
    }
    
}
