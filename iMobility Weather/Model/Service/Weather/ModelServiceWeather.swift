//
//  ModelServiceWeather.swift
//  iMobility Weather
//
//  Created by worker on 17/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Service {
    
    struct Weather: Identifiable {
        
        let id: Int
        let name: String
        private let datetime: TimeInterval
        
        private let weather: [Condition]
        let values: Values
        let wind: Wind
        
    }
    
}

extension Model.Service.Weather: Codable {
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case datetime = "dt"
        case weather
        case values = "main"
        case wind
        
    }
    
}

extension Model.Service.Weather: Equatable { }

extension Model.Service.Weather {
    
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
