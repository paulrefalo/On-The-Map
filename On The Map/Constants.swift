//
//  Constants.swift
//  On The Map
//
//  Created by Paul ReFalo on 10/19/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import UIKit

// MARK: - Constants

struct Constants {
    
    
    // MARK: Udacity 
    struct Udacity {
        static let UdacitySignUpURL = "https://auth.udacity.com/sign-up?next=''"
        static let ApiScheme = "https"
        static let UdacityPostApiSession =  "https://www.udacity.com/api/session"
    }
 

    // MARK: UI
    struct UI {
        //static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).CGColor
        //static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
        // static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        // static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        static let OrangeColor = UIColor(red: 1.0, green: 0.4300, blue: 0.0, alpha: 1.0)
        static let LoginColorTop = UIColor(red: 1.0, green: 0.6500, blue: 0.043, alpha: 1.0).CGColor
        static let LoginColorBottom = UIColor(red: 1.0, green: 0.4300, blue: 0.0, alpha: 1.0).CGColor
    }
    

    
    /* NOTES
     
     Parse
     Parse Application ID: QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr
     REST API Key: QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY
     
     // GETting Student Locations
     let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
     request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
     request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
     let session = NSURLSession.sharedSession()
     let task = session.dataTaskWithRequest(request) { data, response, error in
     if error != nil { // Handle error...
     return
     }
     print(NSString(data: data!, encoding: NSUTF8StringEncoding))
     }
     task.resume()
     
     GET a student location
     let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%221234%22%7D"
     let url = NSURL(string: urlString)
     let request = NSMutableURLRequest(URL: url!)
     request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
     request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
     let session = NSURLSession.sharedSession()
     let task = session.dataTaskWithRequest(request) { data, response, error in
     if error != nil { // Handle error
     return
     }
     print(NSString(data: data!, encoding: NSUTF8StringEncoding))
     }
     task.resume()
     
     POST a student location
     let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
     request.HTTPMethod = "POST"
     request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
     request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}".dataUsingEncoding(NSUTF8StringEncoding)
     let session = NSURLSession.sharedSession()
     let task = session.dataTaskWithRequest(request) { data, response, error in
     if error != nil { // Handle error…
     return
     }
     print(NSString(data: data!, encoding: NSUTF8StringEncoding))
     }
     task.resume()
     
     PUT a student location
     let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/8ZExGR5uX8"
     let url = NSURL(string: urlString)
     let request = NSMutableURLRequest(URL: url!)
     request.HTTPMethod = "PUT"
     request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
     request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Cupertino, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.322998, \"longitude\": -122.032182}".dataUsingEncoding(NSUTF8StringEncoding)
     let session = NSURLSession.sharedSession()
     let task = session.dataTaskWithRequest(request) { data, response, error in
     if error != nil { // Handle error…
     return
     }
     print(NSString(data: data!, encoding: NSUTF8StringEncoding))
     }
     task.resume()
     
     DONE DONE DONE
     GET a session ID from Udacity with POST method
     let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
     request.HTTPMethod = "POST"
     request.addValue("application/json", forHTTPHeaderField: "Accept")
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     request.HTTPBody = "{\"udacity\": {\"username\": \"account@domain.com\", \"password\": \"********\"}}".dataUsingEncoding(NSUTF8StringEncoding)
     let session = NSURLSession.sharedSession()
     let task = session.dataTaskWithRequest(request) { data, response, error in
     if error != nil { // Handle error…
     return
     }
     let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
     print(NSString(data: newData!, encoding: NSUTF8StringEncoding))
     }
     task.resume()
     
     */
     
    
}