//
//  ModelContentForecast.swift
//  iMobility Weather
//
//  Created by worker on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Content {
    
    struct Forecast: Identifiable {
        
        let id: Int
        let service: Model.Service.Forecast
        
    }
    
}

extension Model.Content.Forecast: Equatable { }

extension Model.Content.Forecast {
    
    init(with service: Model.Service.Forecast) {
        self.init(id: Int(service.id.timeIntervalSince1970),
                  service: service)
    }
    
}
