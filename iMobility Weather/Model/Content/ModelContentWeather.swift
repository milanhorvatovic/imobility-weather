//
//  ModelContentWeather.swift
//  iMobility Weather
//
//  Created by worker on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Content {
    
    struct Weather: Identifiable {
        
        let id: Int
        let service: Model.Service.Weather?
        
    }
    
}

extension Model.Content.Weather: Equatable { }

extension Model.Content.Weather {
    
    init(id: Int) {
        self.init(id: id,
                  service: nil)
    }
    
    init(with service: Model.Service.Weather) {
        self.init(id: service.id,
                  service: service)
    }
    
}
