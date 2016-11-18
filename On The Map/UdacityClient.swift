//
//  UdacityClient.swift
//  On The Map
//
//  Created by Paul ReFalo on 10/21/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import Foundation
import MapKit

class UdacityClient : NSObject {
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // globals to store user info
    var udacityKey = String()
    var udacityFirstName = String()
    var udacityLastName = String()
    var udcatiyLongitude = Double()
    var udacityLatitude = Double()
    var udacityMediaLink = String()
    var udacityEmoji = String()
    var udacityAddUserPin = 0
    var userHasPin = false
    var tempEmoji = String()
    var tempLatitude = Double()
    var tempLongitude = Double()
    
    // global sessionID for authentication
    var sessionId = String()
    
    // global array of Student structs
    var studentBody: [Student]
    
    override init() {
        studentBody = [Student]()
    }
    
    // Define globeEmoji and flagEmoi dictionary for use
    let globeEmoji = String(UnicodeScalar(UInt32("1F30E", radix: 16)!))
    var flagEmoji = [String : String]()
    
    // MARK: POST
    
    func taskForPOSTMethod(method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var parametersWithApiKey = parameters
        
        /* 2/3. Build the URL, Configure the request */
        let url = NSURL(string: method)!
        print("URL is \(url)")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            // Special handling for Udacity API, remove first five characters
            let newData = data.subdataWithRange(NSMakeRange(5, data.length-5))
            // Parse data
            let parsedResult = try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            
            self.udacityKey = ((parsedResult["account"] as! [String : AnyObject])["key"] as! String)
            self.sessionId = ((parsedResult["session"] as! [String : AnyObject])["id"] as! String)
            
            print("Udacity Key is \(self.udacityKey) and sessionID is \(self.sessionId)")
            
            completionHandlerForPOST(result: true, error: nil)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func getUserDataFromUdacity(method : String, completionHandler: (result: Bool, error: String?) -> Void) {
        let url = NSURL(string: method)!
        print("URL is \(url)")
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            // Check for errors
            func sendError(error: String) {
                print(error)
                completionHandler(result: false, error: "Error getting Udacity user information")
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Special handling for Udacity API, remove first five characters
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            let parsedResult = try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            
            // print("parsedResult for user is \(parsedResult)")
            
            self.udacityFirstName = ((parsedResult["user"] as! [String: AnyObject])["first_name"] as! String)
            self.udacityLastName = ((parsedResult["user"] as! [String: AnyObject])["last_name"] as! String)
            
            print("Name is \(self.udacityFirstName) \(self.udacityLastName)")
            
            completionHandler(result: true, error: nil)
        }
        task.resume()
    }
    
    func getStudentData(method : String, limit : Int, skip : Int, completionHandler: (result: Bool, error: String?) -> Void) {
        
        var uniqueKeyHash = [ String : Int ]() // Use this hash for quick lookups to avoid duplicates for a student
        
        /* 1. Set the parameters */
        var parameters:[String:AnyObject] = [String:AnyObject]()
        parameters["limit"] = limit
        parameters["skip"] = skip
        parameters["order"] = "-updatedAt"
        
        /* 2/3. Build the URL, Configure the request */
        let url = NSURL(string: method + UdacityClient.escapedParameters(parameters))!
        print("URL is \(url)")
        
        let request = NSMutableURLRequest(URL: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            // Check for errors
            func sendError(error: String) {
                print(error)
                completionHandler(result: false, error: "Error getting Udacity user information")
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.studentBody.removeAll()
            let parsedResult: AnyObject!
            
            
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                completionHandler(result: false, error: "Not able to parse result from server!")
                return
            }
            
            let studentsArray = parsedResult.objectForKey("results") as? [NSMutableDictionary]
            guard studentsArray != nil else {
                completionHandler(result: false, error: "Server error: unparseable results array.")
                return
            }
            
            // dump(studentsArray)
            
            for dictionary in studentsArray! {
                
                // var locationEmoji = dictionary.objectForKey("locationEmoji") as? String
                let lastName = dictionary.objectForKey("lastName") as? String
                let mediaURL = dictionary.objectForKey("mediaURL") as? String
                let firstName = dictionary.objectForKey("firstName") as? String
                
                let uniqueKey = dictionary.objectForKey("uniqueKey") as? String
                if (uniqueKey == nil) || (firstName == nil) || (lastName == nil) || (mediaURL == nil) { continue }
                
                let latitude = CLLocationDegrees(dictionary.objectForKey("latitude") as! Double)
                let longitude = CLLocationDegrees(dictionary.objectForKey("longitude") as! Double)
                
                let emoji = self.getEmoji(uniqueKey!, latitude: latitude, longitude: longitude)
                
                // Add uniqueKey values to Hash for lookup in order to avoid duplicates getting into the StudentBody
                if (uniqueKeyHash[uniqueKey!] != 1) {
                    uniqueKeyHash[uniqueKey!] = 1
                    self.studentBody.append(Student(studentsDictionary : ["firstName" : firstName!, "lastName" : lastName!, "mediaURL": mediaURL!, "uniqueKey" : uniqueKey!, "latitude" : latitude, "longitude" : longitude, "locationEmoji" : emoji]))  // self.globeEmoji
                }
            }
            
            dump(self.studentBody)
            print(self.studentBody[4])
            //dump(self.uniqueKeyHash)
            
            completionHandler(result: true, error: nil)
        }
        task.resume()
    }
    
    // get Location Emoji set into dictionary
    func getEmoji(uniqueKey : String?, latitude : Double, longitude : Double) -> String {
        var emojiResult = String()
        
        // use location to get student country code and flag emoji for table view display; globe emoji as default
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            var placemark:CLPlacemark!
            
            if error == nil && placemarks!.count > 0 {
                placemark = placemarks![0] as CLPlacemark
                
                var emojiString = String()
                let countryCode = placemark.ISOcountryCode
                
                if countryCode != nil {
                    for uS in countryCode!.unicodeScalars {
                        emojiString.append(UnicodeScalar(127397 + uS.value))
                    }
                } else {
                    emojiString = self.globeEmoji
                }
                
                self.flagEmoji[uniqueKey!] = emojiString
                emojiResult = emojiString
            }
        }) // end gelolocation closure
        return emojiResult
    }
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}


struct Student {
    var firstName : String
    var lastName : String
    var mediaURL : String
    
    var uniqueKey : String
    var locationEmoji : String
    
    var latitude : Double
    var longitude : Double
    
    init(studentsDictionary: [String: AnyObject]) {
        firstName = studentsDictionary["firstName"] as! String
        locationEmoji = studentsDictionary["locationEmoji"] as! String

        lastName = studentsDictionary["lastName"] as! String
        mediaURL = studentsDictionary["mediaURL"] as! String
        
        uniqueKey = studentsDictionary["uniqueKey"] as! String
        
        latitude = studentsDictionary["latitude"] as! Double
        longitude = studentsDictionary["longitude"] as! Double
    }
}


