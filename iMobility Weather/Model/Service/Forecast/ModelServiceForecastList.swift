//
//  ModelServiceForecastList.swift
//  iMobility Weather
//
//  Created by worker on 17/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Service.Forecast {
    
    struct List {
        
        let list: [Model.Service.Forecast]
        
    }
    
}

extension Model.Service.Forecast.List: Codable { }
extension Model.Service.Forecast.List: Equatable { }
