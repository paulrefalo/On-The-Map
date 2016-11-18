//
//  AddPinViewController.swift
//  On The Map
//
//  Created by Paul ReFalo on 11/11/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class AddPinViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    var keyboardOnScreen = false
    var placemark: MKPlacemark!
    var longitude = Double()
    var latitude = Double()
    let globeEmoji = String(UnicodeScalar(UInt32("1F30E", radix: 16)!))
    

    @IBOutlet weak var mediaLinkView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var blueBox: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findLocation: UIButton!
    @IBOutlet weak var topText1: UILabel!
    @IBOutlet weak var topText2: UILabel!
    @IBOutlet weak var topText3: UILabel!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    
    override func viewDidLoad() {
        self.topText2.font = UIFont.boldSystemFontOfSize(28.0)
        locationTextField.attributedPlaceholder = NSAttributedString(string: "Enter Your Location Here", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        findLocation.layer.cornerRadius = 5
        
        self.hideKeyboardWhenTappedAround() 
        
        linkTextField.hidden = true
        linkTextField.enabled = false
        
        submitButton.hidden = true
        submitButton.enabled = false
        
        locationTextField.delegate = self
        linkTextField.delegate = self
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(keyboardWillHide))
        subscribeToNotification(UIKeyboardDidShowNotification, selector: #selector(keyboardDidShow))
        subscribeToNotification(UIKeyboardDidHideNotification, selector: #selector(keyboardDidHide))
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    @IBAction func getLocation(sender: AnyObject) {     // Preview location on map
        
        guard locationTextField.text != "" else {
            let alert = UIAlertController(title: "Error", message: "Must enter a valid location.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // Configure UI
        blueBox.alpha = 0
        mapView.alpha = 1
        findLocation.enabled = false
        findLocation.hidden = true
        
        mediaLinkView.alpha = 1
        linkTextField.hidden = false
        linkTextField.enabled = true
        
        linkTextField.attributedPlaceholder = NSAttributedString(string: "Enter a Link to Share Here", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        
        // Use location to add pin
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationTextField.text!) { (placemarks, error) -> Void in
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                return
            }
            
            guard placemarks!.count > 0 else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "Error", message: "Could Not Find Location.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                return
            }

            // dump(placemarks)
            
            dispatch_async(dispatch_get_main_queue(), {
                var emojiString = String()
                self.placemark = MKPlacemark(placemark: placemarks![0])
                self.mapView.addAnnotation(self.placemark)
                let region = MKCoordinateRegionMakeWithDistance(self.placemark.coordinate, 100000, 100000)
                self.mapView.setRegion(region, animated: true)
                let location = self.placemark?.location
                let coordinate = location?.coordinate
                UdacityClient.sharedInstance().tempLatitude = coordinate!.latitude
                UdacityClient.sharedInstance().tempLongitude = coordinate!.longitude
                print("location is \(location)")
                let countryCode = self.placemark?.ISOcountryCode
                if countryCode != nil {
                    for uS in countryCode!.unicodeScalars {
                        emojiString.append(UnicodeScalar(127397 + uS.value))
                    }
                } else {
                    emojiString = self.globeEmoji
                }
                
                UdacityClient.sharedInstance().tempEmoji = emojiString

                // print("Country code is \(countryCode) and emoji is \(emojiString)")
                self.submitButton.enabled = true
                self.submitButton.hidden = false
            })
        }
    }

    @IBAction func submitButtonPressed(sender: AnyObject) {
        guard linkTextField.text != "" else {
            let alert = UIAlertController(title: "Error", message: "Must enter a media link.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        print("submit button pressed and userHasPin")
        
        // Udacity Client:  first name, last name stored.  Updated lat, long, media link and emoji
        UdacityClient.sharedInstance().udacityMediaLink = linkTextField.text!
        
        UdacityClient.sharedInstance().udacityAddUserPin = 1  // update flag to include user on the map
        UdacityClient.sharedInstance().udacityEmoji = UdacityClient.sharedInstance().tempEmoji
        UdacityClient.sharedInstance().flagEmoji[UdacityClient.sharedInstance().udacityKey] = UdacityClient.sharedInstance().tempEmoji
        UdacityClient.sharedInstance().udacityLatitude = UdacityClient.sharedInstance().tempLatitude
        UdacityClient.sharedInstance().udcatiyLongitude = UdacityClient.sharedInstance().tempLongitude
        
        UdacityClient.sharedInstance().studentBody.append(Student(studentsDictionary : [
            "firstName" : UdacityClient.sharedInstance().udacityFirstName,
            "lastName" : UdacityClient.sharedInstance().udacityLastName,
            "mediaURL": UdacityClient.sharedInstance().udacityMediaLink,
            "uniqueKey" : UdacityClient.sharedInstance().udacityKey,
            "latitude" : UdacityClient.sharedInstance().udacityLatitude,
            "longitude" : UdacityClient.sharedInstance().udcatiyLongitude,
            "locationEmoji" : UdacityClient.sharedInstance().udacityEmoji]))
        
        dump(UdacityClient.sharedInstance().studentBody)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancelButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if locationTextField.isFirstResponder() == true {
            locationTextField.placeholder = ""
        }
        
        if linkTextField.isFirstResponder() == true {
            linkTextField.placeholder = ""
        }
    }
    

}

// MARK: - LoginViewController: UITextFieldDelegate

extension AddPinViewController {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= 0 // keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += 0 // keyboardHeight(notification)
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(locationTextField)
        resignIfFirstResponder(linkTextField)
    }
    
    // Udacity Sign Up Button
    @IBAction func UdacitySignUp(sender: UIButton) {
        let udacitySignUpURL = Constants.Udacity.UdacitySignUpURL
        UIApplication.sharedApplication().openURL(NSURL(string: udacitySignUpURL)!)
    }
}


// MARK: - LoginViewController (Notifications)

extension AddPinViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}