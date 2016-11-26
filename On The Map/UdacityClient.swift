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
    var session = URLSession.shared
    
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
    var parseObjectID = String()
    
    // global sessionID for authentication
    var sessionId = String()
    
    // Define globeEmoji and flagEmoi dictionary for use
    let globeEmoji = String(UnicodeScalar(Int("1F30E", radix: 16)!)!)   // 🌎

    var flagEmoji = [String : String]()
    
    // function gets key and sessionID from Udacity.  Returns true if successful
    func getKeyAndSession(_ postJsonBody : AnyObject, completionHandler: @escaping (_ result: Bool, _ error: String?) -> Void) {
        
        /* 1. Set the parameters */
        /* 2/3. Build the URL, Configure the request */
        let jsonBody = postJsonBody as! String
        
        
        /* 4. Make the request */

        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Check for errors
            func sendError(_ error: String) {
                // print("Send error is called")
                
                print(error)
                
                completionHandler(false, "\(error)")
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let status = (response as? HTTPURLResponse)?.statusCode
                print("The status from get user data is  \(status)")
                sendError("Your key and sessionID request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            


            do {
                let range = Range(uncheckedBounds: (5, data.count))
                let newData = data.subdata(in: range) /* subset response data! */
                
                let parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
                
                UdacityClient.sharedInstance().udacityKey = ((parsedResult["account"] as! [String : AnyObject])["key"] as! String)
                UdacityClient.sharedInstance().sessionId = ((parsedResult["session"] as! [String : AnyObject])["id"] as! String)
                print("Key is \(UdacityClient.sharedInstance().udacityKey) and sessionID is \(UdacityClient.sharedInstance().sessionId)")
                completionHandler(true, nil)

                
            } catch {
                sendError("Error parsing and setting key and sessionID!")
                return
            }
            
        
        }
        task.resume()
    }

    
    func postStudentLocation(_ postJsonBody : AnyObject, completionHandler: @escaping (_ result: Bool, _ error: String?) -> Void) {
        
        /* 1. Set the parameters */
        /* 2/3. Build the URL, Configure the request */
        let jsonBody = postJsonBody as! String
        
        print("******* Hello from postStudentLocation in Client.  jsonBody is \(jsonBody)")
        /* 4. Make the request */

        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)

        request.httpMethod = "POST"
        // ******* added fishy
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        print("Request for student location post is:  \(request)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Check for errors
            func sendError(_ error: String) {
                print(error)
                completionHandler(false, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your post request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let status = (response as? HTTPURLResponse)?.statusCode
                print("The status from get user data is  \(status)")
                sendError("Your post student location request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the post request!")
                return
            }
            print("Student Location Post request successful.  Data from post student location:")
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
            
            let parsedResult = try! JSONSerialization.jsonObject(with: data, options:.allowFragments) as! [String:AnyObject]
            
            self.parseObjectID = ((parsedResult["objectId"]  as! String))
            
            print("ObjectID is \(self.parseObjectID) ")
            
            completionHandler(true, nil)

        }
        task.resume()
    }
    
    func putStudentLocation(_ postJsonBody : AnyObject, objectID : String, completionHandler: @escaping (_ result: Bool, _ error: String?) -> Void) {
        
        /* 1. Set the parameters */
        /* 2/3. Build the URL, Configure the request */
        let jsonBody = postJsonBody as! String
        
        print("******* Hello from putStudentLocation in Client.  jsonBody is \(jsonBody)")
        /* 4. Make the request */
        
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation/\(objectID)")!)
        print("Your PUt request is:  \(request)")
        
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        print("Request for student location post is:  \(request)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Check for errors
            func sendError(_ error: String) {
                print(error)
                completionHandler(false, "Error getting Udacity user information")
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your put request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let status = (response as? HTTPURLResponse)?.statusCode
                print("The status from get user data is  \(status)")
                sendError("Your put student location request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the put request!")
                return
            }
            print("Student Location Put request successful.  Data from put student location:")
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)

            completionHandler(true, nil)
        }
        task.resume()
    }
    
    func udacityLogout(completionHandler: @escaping (_ result: Bool, _ error: String?) -> Void) {
        let method = "https://www.udacity.com/api/session"
        let url = URL(string: method)!
        var request = URLRequest(url: url) // URLRequest(url : url!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = URLSession.shared
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            
            // Check for errors
            func sendError(_ error: String) {
                print(error)
                completionHandler(false, "Logout Error")
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your logout request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let status = (response as? HTTPURLResponse)?.statusCode
                print("The status from get user data is  \(status)")
                sendError("Your logout request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard data != nil else {
                sendError("No data was returned by the get-user-data request!")
                return
            }
            
            // Udacity Logut Successful
            completionHandler(true, nil)
        }
        task.resume()
    }

    func getUserDataFromUdacity(_ method : String, completionHandler: @escaping (_ result: Bool, _ error: String?) -> Void) {
        let url = URL(string: method)!
        let request = URLRequest(url: url) // URLRequest(url : url!)

        let session = URLSession.shared
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in

            // Check for errors
            func sendError(_ error: String) {
                print(error)
                completionHandler(false, "Error getting Udacity user information")
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your get-user-data request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let status = (response as? HTTPURLResponse)?.statusCode
                print("The status from get user data is  \(status)")
                sendError("Your get-user-data request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the get-user-data request!")
                return
            }
            
            // Special handling for Udacity API, remove first five characters
            let range = Range(uncheckedBounds: (5, data.count))              //  previously  let newData = data.subdata(in: 0..<data.count - 5)
            let newData = data.subdata(in: range) /* subset response data! */
            let parsedResult = try! JSONSerialization.jsonObject(with: newData, options:.allowFragments) as! [String:AnyObject]

            
            // print("parsedResult for user is \(parsedResult)")
            
            self.udacityFirstName = ((parsedResult["user"] as! [String: AnyObject])["first_name"] as! String)
            self.udacityLastName = ((parsedResult["user"] as! [String: AnyObject])["last_name"] as! String)
            
            print("Name is \(self.udacityFirstName) \(self.udacityLastName)")
            
            completionHandler(true, nil)
        }
        task.resume()
    }
    
    func getStudentData(_ method : String, limit : Int, skip : Int, completionHandler: @escaping (_ result: Bool, _ error: String?) -> Void) {

        var uniqueKeyHash = [ String : Int ]() // Use this hash for quick lookups and to avoid duplicates for a student
        
        /* 1. Set the parameters */
        var parameters:[String:AnyObject] = [String:AnyObject]()
        parameters["limit"] = limit as AnyObject?
        parameters["skip"] = skip as AnyObject?
        parameters["order"] = "-updatedAt" as AnyObject?
        
        /* 2/3. Build the URL, Configure the request */
        let url = URL(string: method + UdacityClient.escapedParameters(parameters))!
        
        var request = URLRequest(url: url) // URLRequest(url : url!)

        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        
        /* 4. Make the request */
        //  task was: let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in

        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            // Check for errors
            func sendError(_ error: String) {
                print(error)
                completionHandler(false, "Error getting Udacity user information")
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let status = (response as? HTTPURLResponse)?.statusCode
                print("The status from get user data is  \(status)")
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            // let parsedResult : [String:AnyObject] = try! JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
            
            let parsedResult = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSMutableDictionary
            // print("parsedResult for getStudentData is \n\(parsedResult)")
            let studentsArray = parsedResult.object(forKey: "results") as? [NSMutableDictionary]
            // dump(studentsArray)
            
            guard studentsArray != nil else {
                completionHandler(false, "Server error: unparseable results array.")
                return
            }
            
            for dictionary in studentsArray! { // removed ! from studentsArray
                
                let lastName = dictionary.object(forKey: "lastName") as? String
                let mediaURL = dictionary.object(forKey: "mediaURL") as? String
                let firstName = dictionary.object(forKey: "firstName") as? String
                
                let uniqueKey = dictionary.object(forKey: "uniqueKey") as? String
                if (uniqueKey == nil) || (firstName == nil) || (lastName == nil) || (mediaURL == nil) { continue }
                
                let latitude = CLLocationDegrees(dictionary.object(forKey: "latitude") as! Double)
                let longitude = CLLocationDegrees(dictionary.object(forKey: "longitude") as! Double)
                
                var emoji = self.globeEmoji // default
                emoji = self.getEmoji(uniqueKey!, latitude: latitude, longitude: longitude)
                
            
                
                // Add uniqueKey values to Hash for lookup in order to avoid duplicates getting into the StudentBody
                if (uniqueKeyHash[uniqueKey!] != 1) {
                    uniqueKeyHash[uniqueKey!] = 1
                    StudentModel.sharedInstance().studentBody.append(Student(studentsDictionary : ["firstName" : firstName! as AnyObject, "lastName" : lastName! as AnyObject, "mediaURL": mediaURL! as AnyObject, "uniqueKey" : uniqueKey! as AnyObject, "latitude" : latitude as AnyObject, "longitude" : longitude as AnyObject, "locationEmoji" : emoji as AnyObject]))  // self.globeEmoji
                }
            }
            dump(uniqueKeyHash)
            dump(StudentModel.sharedInstance().studentBody)
            
            completionHandler(true, nil)

        }
        task.resume()
    }
    
    // MARK: Get Emoji
    
    // get Location Emoji set into dictionary
    func getEmoji(_ uniqueKey : String!, latitude : Double, longitude : Double) -> String {
        var emojiResult = String()

        // use location to get student country code and flag emoji for table view display; globe emoji as default
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            var placemark:CLPlacemark!
            
            if error == nil && placemarks!.count > 0 {
                placemark = placemarks![0] as CLPlacemark
                
                var emojiString = String()
                let countryCode = placemark.isoCountryCode
                
                if countryCode != nil {
                    let base : UInt32 = 127397
                    for v in (countryCode?.unicodeScalars)! {
                        emojiString.unicodeScalars.append(UnicodeScalar(base + v.value)!)
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
    
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
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


