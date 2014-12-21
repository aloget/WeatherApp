//
//  Location.swift
//  WeatherApp
//
//  Created by Anna on 15/12/14.
//  Copyright (c) 2014 Anna. All rights reserved.
//

import UIKit
import CoreLocation

class Location: NSObject {
    
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    
    var city = ""
    var country = ""
    
    func locationWithJSON(#JSONDictionary:Dictionary<String, AnyObject>){
        
        if let categoryCoord = JSONDictionary["coord"] as? NSDictionary {
            if let latitude = categoryCoord["lat"] as? Double {
                self.latitude = latitude
            }
            if let longitude = categoryCoord["lon"] as? Double {
                self.longitude = longitude
            }
            
        }
        if let categorySys = JSONDictionary["sys"] as? NSDictionary{
        if let aCountry = categorySys["country"] as? String {
                country = aCountry
            }
        }
        if let aCity = JSONDictionary["name"] as? String {
            city = aCity
        }

    }
    
    func locationWithCLLocationCoordinate(coordinate:CLLocationCoordinate2D?){
        if let coord = coordinate {
            latitude = coord.latitude
            longitude = coord.longitude
        }
        
    }
    
    func reset() {
        latitude = 0.0
        longitude = 0.0
        
        city = ""
        country = ""
    }
   
}
