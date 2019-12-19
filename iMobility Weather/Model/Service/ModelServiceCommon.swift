//
//  ModelServiceCommon.swift
//  iMobility Weather
//
//  Created by worker on 17/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Service {
    
    struct Condition: Identifiable {
        
        let id: Int
        let name: String
        let description: String
        let icon: String
        
    }
    
}

extension Model.Service.Condition: Codable {
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case name = "main"
        case description
        case icon
        
    }
    
}

extension Model.Service.Condition: Equatable { }

extension Model.Service {
    
    struct Values {
        
        let temperature: Double
        let temperatureFeelsLike: Double
        let temperatureMin: Double
        let temperatureMax: Double
        let pressure: Int
        let humidity: Int
        
    }
    
}

extension Model.Service.Values: Codable {
    
    private enum CodingKeys: String, CodingKey {
        
        case temperature = "temp"
        case temperatureFeelsLike = "feels_like"
        case temperatureMin = "temp_min"
        case temperatureMax = "temp_max"
        case pressure
        case humidity
        
    }
    
}

extension Model.Service.Values: Equatable { }

extension Model.Service {
    
    struct Wind {
        
        let speed: Double
        let degree: Int?
        
    }
    
}

extension Model.Service.Wind: Codable {
    
    private enum CodingKeys: String, CodingKey {
        
        case speed
        case degree = "deg"
        
    }
    
}

extension Model.Service.Wind: Equatable { }
