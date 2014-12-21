//
//  Weather.swift
//  WeatherApp
//
//  Created by Anna on 15/12/14.
//  Copyright (c) 2014 Anna. All rights reserved.
//

import UIKit

class Weather: NSObject {
    
    var type = ""
    
    var tempAvg = 0
    var tempMin = 0
    var tempMax = 0
    
    var humidity = 0
    var pressure = 0
    var wind = 0
    
    var icon:NSData?
    
    func weatherWithJSON(#JSONDictionary: Dictionary<String, AnyObject>){
        
        
        if let categoryWeather = JSONDictionary["weather"] as? NSArray{
            if let firstWeather = categoryWeather[0] as? NSDictionary{
                if let aWeatherType = firstWeather["main"] as? String {
                    type = aWeatherType
                }
                if let anImage = firstWeather["icon"] as? String{
                    let iconCode = anImage
                    let urlStr = "http://openweathermap.org/img/w/\(iconCode).png"
                    let url = NSURL(string: urlStr)
                    var request = NSURLRequest(URL: url!)
                    var response:NSURLResponse?
                    var error:NSError?
                    var responseData = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&error)
                    
                    if (error != nil) {
                        NSLog("%@", "Couldn't get an image: \(error)")
                    }
                    else {
                      icon = responseData
                    }
                    
                     }
                 }
        }
    

        
        if let categoryMain = JSONDictionary["main"] as? NSDictionary{
            if let aTemp = categoryMain["temp"] as? Float {
                tempAvg = Int(aTemp - 273.15) //Celcius
            }
            if let aTempMin = categoryMain["temp_min"] as? Float {
                tempMin = Int(aTempMin - 273.15)
            }
            if let aTempMax = categoryMain["temp_max"] as? Float {
                tempMax = Int(aTempMax - 273.15)
                
            }
            if let aPressure = categoryMain["pressure"] as? Int {
                pressure = aPressure
                
                
            }
            if let aHumidity = categoryMain["humidity"] as? Int{
                humidity = aHumidity
            }
        }
        if let categoryWind = JSONDictionary["wind"] as? NSDictionary {
            if let aWind = categoryWind["speed"] as? Float {
                wind = Int(aWind)
            }
        }

    }
    
    
   
}
