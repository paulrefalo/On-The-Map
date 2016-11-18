//
//  TableViewController.swift
//  On The Map
//
//  Created by Paul ReFalo on 10/28/16.
//  Copyright © 2016 QSS. All rights reserved.
//


import Foundation
import MapKit
import UIKit

class TableViewController: UITableViewController {
    
    let globeEmoji = String(UnicodeScalar(UInt32("1F30E", radix: 16)!))
    
    @IBAction func reloadButton(sender: AnyObject) {
        UdacityClient.sharedInstance().studentBody.removeAll()
        self.getStudentData()
    }
    
    @IBAction func addPin(sender: AnyObject) {
        print("addPin pressed")
        if UdacityClient.sharedInstance().userHasPin == true {
            print("userHasPin is true inside addPin on MapVC")
            
            let alert = UIAlertController(title: "You already have a pin", message: "Would you like to Overwrite your current location?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default, handler: self.overwritePin))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            return
            
        } else {
            print("userHasPin is false in addPin on MapVC")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("addPinNavigationController")
            self.presentViewController(nextViewController, animated:true, completion:nil)
            
        }
    }
    
    func overwritePin(alert: UIAlertAction!) {
        print("overwritePin called")
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("addPinNavigationController")
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UdacityClient.sharedInstance().studentBody.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MapsTableViewCell")!
        let studentData = UdacityClient.sharedInstance().studentBody[indexPath.row]
        
        if let flag = UdacityClient.sharedInstance().flagEmoji[studentData.uniqueKey] {
            print(flag)
            cell.textLabel?.text = flag + "  " + studentData.firstName + " " + studentData.lastName
        } else {
            print("No flag")
            cell.textLabel?.text = UdacityClient.sharedInstance().globeEmoji + "  " + studentData.firstName + " " + studentData.lastName
        }
        
        print("The udacity emoji is \(UdacityClient.sharedInstance().udacityEmoji)")
        
        
        cell.detailTextLabel?.text = studentData.mediaURL
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentData = UdacityClient.sharedInstance().studentBody[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: studentData.mediaURL)!)
    }
    
    func getStudentData() {
        let requestString = "https://parse.udacity.com/parse/classes/StudentLocation"
        print(requestString)
        let _ = Int(arc4random_uniform(200))
        UdacityClient.sharedInstance().getStudentData(requestString, limit : 50, skip : 0) { (results, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    UdacityClient.sharedInstance().udacityAddUserPin = 0
                    UdacityClient.sharedInstance().userHasPin = false
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // get Location Emoji set into dictionary
    func getEmoji(uniqueKey : String?, latitude : Double, longitude : Double) -> String {
        var emojiResult = String()
        // print("getEmoji function \(uniqueKey) \(latitude) \(longitude)")
        
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
                print("EmojiString is \(emojiString)")
                UdacityClient.sharedInstance().flagEmoji[uniqueKey!] = emojiString
                emojiResult = emojiString
            } else {
                print("Location error \(error)")
            }
        }) // end gelolocation closure
        return emojiResult
    }
}

