//
//  ModelServiceForecast.swift
//  iMobility Weather
//
//  Created by worker on 17/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Service {
    
    struct Forecast {
        
        private let datetime: TimeInterval
        private let weather: [Condition]
        let values: Values
        let wind: Wind
        
    }
    
}

extension Model.Service.Forecast: Codable {
    
    private enum CodingKeys: String, CodingKey {
        
        case datetime = "dt"
        case weather
        case values = "main"
        case wind
        
    }
    
}

extension Model.Service.Forecast: Identifiable {
    
    var id: Date {
        return self.date
    }
    
}

extension Model.Service.Forecast: Equatable { }

extension Model.Service.Forecast {
    
    var date: Date {
        return Date(timeIntervalSince1970: self.datetime)
    }
    
    var condition: Model.Service.Condition {
        guard let value = self.weather.first else {
            fatalError("Condition isn't populated in the weather! This should never occur.")
        }
        return value
    }
    
}
