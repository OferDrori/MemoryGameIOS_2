//
//  Location.swift
//  Memory Game
//
//  Created by user196233 on 5/23/21.
//

import Foundation

class LocationDTO: Codable {
    var longitude : Double = 0
    var latitude : Double = 0

    init (){}
    
    init (latitude: Double, longitude: Double)
    {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public var toString: String {
        return "latitude: \(self.latitude), longitude: \(self.longitude)"
    }
}
