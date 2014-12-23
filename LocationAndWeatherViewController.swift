//
//  LocationAndWeatherViewController.swift
//  WeatherApp
//
//  Created by Anna on 08/12/14.
//  Copyright (c) 2014 Anna. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import Social


class LocationAndWeatherViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    //MARK: - initialization

    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    
    //MARK: - constants
    
    enum Error {
        case None, LocationUnknown, LocationNotAvailable, LocationFailure, Other
    }
    
    let APIKey = "a351977676a87d2a47131e3eb1f9e26e"
    
    
    //MARK: data
    var location:Location!
    var weather:Weather!
    
    

    //MARK: outlets
   
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var tempAvg: UILabel!
    @IBOutlet weak var tempMinAndMax: UILabel!
    @IBOutlet weak var weatherType: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var wind: UILabel!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: - sharing
    
    @IBOutlet weak var facebookShareButton: UIButton!
    @IBOutlet weak var twitterShareButton: UIButton!
    
    
    @IBAction func share(sender: UIButton) {
        if sender == facebookShareButton {
            shareWithServiceType(SLServiceTypeFacebook)
        }
        if sender == twitterShareButton {
            shareWithServiceType(SLServiceTypeTwitter)
        }
    }
    
    func shareWithServiceType(serviceType:String){
        if SLComposeViewController.isAvailableForServiceType(serviceType) {
            let sharingSheet = SLComposeViewController(forServiceType: serviceType)
            sharingSheet.setInitialText("Now it's \(weatherType.text!) and \(tempAvg.text!) in \(locationLabel.text!). #Via WeatherApp.")
            self.presentViewController(sharingSheet, animated: true, completion: nil)
        }
        else {
            NSLog("%@", "Social services are not available")
    
            let alert = UIAlertController(title: "Не получилось!", message:  "Вам необходимо авторизоваться через Настройки.", preferredStyle: UIAlertControllerStyle.Alert)
            
            var action:UIAlertAction! = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
              self.dismissErrorWindow()
            })
            
            alert.addAction(action)
        
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    func dismissErrorWindow () {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    //MARK: - UISearchBarDelegate
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        NSLog("%@", "end editing")

    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        NSLog("%@", "Search button clicked")
        if searchBar.text != "" {
            self.location.city = searchBar.text
            updateTheWeatherForLocation(byCoordinates: false)
        }
        
        self.resignFirstResponder()

    }
    
    //MARK: - update button
    
    @IBAction func update(sender: UIBarButtonItem) {
        updateTheWeatherForLocation(byCoordinates: true)
    }
    
    
    //MARK: - initiate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        resetTheView()
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if isLocationServiceAvailable() {
          authorizateForLocationService()
        }
        else {
            activityIndicator.stopAnimating()
            insertMessage(self.error)
        }
    }
    
    //MARK: - Location
    
    var manager:CLLocationManager?
    var error:Error = .None
    
    //MARK:CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        activityIndicator.startAnimating()
        self.error = .None
        updatedToLocation(locations.last as? CLLocation)
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        if (error.code == CLError.LocationUnknown.rawValue) {
            self.error = .LocationUnknown
            return
        }
        else if (error.code == CLError.Denied.rawValue) { self.error = .LocationNotAvailable }
        else { self.error = .LocationFailure }
        insertMessage(self.error)
        
    }
    
     func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if isLocationServiceAvailable() {
               manager!.startUpdatingLocation()
            }
        else {
            activityIndicator.stopAnimating()
            insertMessage(self.error)
        }
        
    }
    
    //MARK:custom
    
    func isLocationServiceAvailable() -> Bool {
        let status:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.Restricted || status == CLAuthorizationStatus.Denied || !CLLocationManager.locationServicesEnabled() {
            self.error = .LocationNotAvailable
            return false
        }
        return true
    }
    
    
    func authorizateForLocationService() {
            
            self.manager = CLLocationManager()
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
                manager!.requestWhenInUseAuthorization()
            }

            self.location = Location()
            self.weather = Weather()
            self.manager!.delegate = self
            self.manager!.desiredAccuracy = kCLLocationAccuracyKilometer
            self.manager!.distanceFilter = 1000.00

    }


    func updatedToLocation(location:CLLocation?){
        
        //var coord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 55.58, longitude: 36.69) - if geolocation is down, test with this data going to the next line
        
        if let loc = location {
         activityIndicator.startAnimating()
            
         self.location.locationWithCLLocationCoordinate(loc.coordinate)
         updateTheWeatherForLocation(byCoordinates: true)
            
         activityIndicator.stopAnimating()
    
        }
        else {
            NSLog("%@","Couldn't get the location, trying again")
            self.error = .LocationUnknown
        }
        
    }
    
    //MARK: - Weather

    func updateTheWeatherForLocation(#byCoordinates: Bool) {
        
        var urlStr = ""
      
        if byCoordinates {
         
            urlStr = "http://api.openweathermap.org/data/2.5/weather?lat=\(self.location.latitude)&lon=\(self.location.longitude)&&APPID=\(APIKey)"
            
        }
        else {
            urlStr = "http://api.openweathermap.org/data/2.5/weather?q=\(self.location.city)&&&APPID=\(APIKey)"
        }
        
        
        let url = NSURL(string: urlStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!.stringByReplacingOccurrencesOfString(" ", withString: "_" ))

        var request = NSURLRequest(URL: url!)
        var response:NSURLResponse?
        var error:NSError?
        var responseData = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&error)
        
        if (error != nil) {
            NSLog("%@", "HTTP request failed with error: \(error)")
            self.error = .Other
        }
        else {
            var parsingError:NSError?
            var JSON: AnyObject? = NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions.MutableContainers, error: &parsingError)
            
            if (parsingError == nil) {
                self.error = .None
                var JSONDictionary = JSON as Dictionary<String, AnyObject>
                self.location.locationWithJSON(JSONDictionary: JSONDictionary)
                self.weather.weatherWithJSON(JSONDictionary: JSONDictionary)
            }
            else {
                NSLog("%@", "Couldn't get the JSON from API data")
                self.error = .Other
            }
        }
        
        //if there's no internet connection
        /* let fileUrl = "/Users/anna/Desktop/weather.json"
        var responseData = NSData(contentsOfFile: fileUrl)
        var parsingError:NSError?
        var JSON: AnyObject? = NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions.MutableContainers, error: &parsingError)
        
        if (parsingError == nil) {
            var JSONDictionary = JSON as Dictionary<String, AnyObject>
            self.location.locationWithJSON(JSONDictionary: JSONDictionary)
            self.weather.weatherWithJSON(JSONDictionary: JSONDictionary)
        }
        else {
            NSLog("%@", "Couldn't get the JSON from API data")
            self.error = .Other
        }
        */
        
        
        if (self.error == .None) {
            insertTheData()
        }
        else {
            insertMessage(self.error)
        }
       
        
    }
    
    
    //MARK: - View
    
    func insertTheData() {
        
        locationLabel.text = "\(location.city)"
        
        tempAvg.text = "\(weather.tempAvg)C"
        tempMinAndMax.text = "\(weather.tempMin)...\(weather.tempMax)C"
        weatherType.text = weather.type
        
        pressure.text = "Pressure \(weather.pressure) hPa"
        humidity.text = "Humidity \(weather.humidity)%"
        wind.text = "Wind \(weather.wind) mps"
        
        //comment if there's no internet connection
        image.image = UIImage(data: weather.icon!)
        
        if facebookShareButton.hidden {
            facebookShareButton.hidden = false
            twitterShareButton.hidden = false
        }
        
        
    }
    
    func insertMessage(message:Error){
        
          resetTheView()
          if (message == .LocationNotAvailable) {
            locationLabel.text = "Извините, мы не можем определить ваше местоположение. Вам нужно активировать службы геолокации."
          }
          else if message == .LocationFailure {
            locationLabel.text = "Что-то пошло не так, пока мы определяли, где вы находитесь. Попробуйте позднее!"
          }
          else if (message == .Other){
            locationLabel.text = "Что-то пошло не так, пока мы определяли погоду. Попробуйте позднее!"
          }
    }
    
    func resetTheView() {
        
        locationLabel.text = ""
        image.image = nil //...
        tempAvg.text = ""
        tempMinAndMax.text = ""
        weatherType.text = ""
        pressure.text = ""
        humidity.text = ""
        wind.text = ""
        
        facebookShareButton.hidden = true
        twitterShareButton.hidden = true
    }
    
    
}