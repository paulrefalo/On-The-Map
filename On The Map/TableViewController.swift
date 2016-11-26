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
    
    let globeEmoji = String(UnicodeScalar(Int("1F30E", radix: 16)!)!)   // 🌎
    
    @IBAction func logoutPressed(_ sender: Any) {
        StudentModel.sharedInstance().studentBody.removeAll()
        UdacityClient.sharedInstance().userHasPin = false
        UdacityClient.sharedInstance().udacityAddUserPin = 0
        
        UdacityClient.sharedInstance().udacityLogout{ (results, error) in
            if error != nil {
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Logout Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
            // Successful Udacity Logout
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func addPin(_ sender: AnyObject) {
        print("addPin pressed")
        if UdacityClient.sharedInstance().userHasPin == true {
            print("userHasPin is true inside addPin on MapVC")
            
            let alert = UIAlertController(title: "You already have a pin", message: "Would you like to Overwrite your current location?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: self.overwritePin))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            return
            
        } else {
            print("userHasPin is false in addPin on MapVC")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "addPinNavigationController")
            self.present(nextViewController, animated:true, completion:nil)
            
        }
    }
    
    func overwritePin(_ alert: UIAlertAction!) {
        print("overwritePin called")
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "addPinNavigationController")
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.sharedInstance().studentBody.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapsTableViewCell")!
        let studentData = StudentModel.sharedInstance().studentBody[indexPath.row]
        
        if let flag = UdacityClient.sharedInstance().flagEmoji[studentData.uniqueKey] {
            // print("flag is \(flag)")
            cell.textLabel?.text = flag + "  " + studentData.firstName + " " + studentData.lastName
        } else {
            // print("No flag")
            cell.textLabel?.text = UdacityClient.sharedInstance().globeEmoji + "  " + studentData.firstName + " " + studentData.lastName
        }
        
        // print("The udacity emoji is \(UdacityClient.sharedInstance().udacityEmoji)")
        
        cell.detailTextLabel?.text = studentData.mediaURL
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentData = StudentModel.sharedInstance().studentBody[indexPath.row]
        UIApplication.shared.openURL(URL(string: studentData.mediaURL)!)
    }
    
    func getStudentData() {
        let requestString = "https://parse.udacity.com/parse/classes/StudentLocation"
        let _ = Int(arc4random_uniform(200))
        UdacityClient.sharedInstance().getStudentData(requestString, limit : 100, skip : 0) { (results, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                DispatchQueue.main.async {
                    UdacityClient.sharedInstance().udacityAddUserPin = 0
                    UdacityClient.sharedInstance().userHasPin = false
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // get Location Emoji set into dictionary
    func getEmoji(_ uniqueKey : String?, latitude : Double, longitude : Double) -> String {
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
                let countryCode = placemark.isoCountryCode
                
                if countryCode != nil {
                    let base : UInt32 = 127397
                    for v in (countryCode?.unicodeScalars)! {
                        emojiString.unicodeScalars.append(UnicodeScalar(base + v.value)!)
                    }
                } else {
                    emojiString = self.globeEmoji
                }

                // print("EmojiString is \(emojiString)")
                UdacityClient.sharedInstance().flagEmoji[uniqueKey!] = emojiString
                emojiResult = emojiString
            } else {
                print("Location error \(error)")
            }
        }) // end gelolocation closure
        return emojiResult
    }
}

