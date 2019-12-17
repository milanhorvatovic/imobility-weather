//
//  ModelServiceWeatherList.swift
//  iMobility Weather
//
//  Created by worker on 17/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Service.Weather {
    
    struct List {
        
        let list: [Model.Service.Weather]
        
    }
    
}

extension Model.Service.Weather.List: Codable { }
extension Model.Service.Weather.List: Equatable { }
