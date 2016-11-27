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
    let globeEmoji = String(describing: UnicodeScalar(UInt32("1F30E", radix: 16)!))
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
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
        self.topText2.font = UIFont.boldSystemFont(ofSize: 28.0)
        locationTextField.attributedPlaceholder = NSAttributedString(string: "Enter Your Location Here", attributes: [NSForegroundColorAttributeName: UIColor.white])
        findLocation.layer.cornerRadius = 5
        
        self.hideKeyboardWhenTappedAround() 
        
        linkTextField.isHidden = true
        linkTextField.isEnabled = false
        
        submitButton.isHidden = true
        submitButton.isEnabled = false
        
        locationTextField.delegate = self
        linkTextField.delegate = self
        
        mapView.delegate = self
        // self.showActivityIndicator(uiView: mapView)
        
        subscribeToNotification(NSNotification.Name.UIKeyboardWillShow.rawValue, selector: #selector(keyboardWillShow))
        subscribeToNotification(NSNotification.Name.UIKeyboardWillHide.rawValue, selector: #selector(keyboardWillHide))
        subscribeToNotification(NSNotification.Name.UIKeyboardDidShow.rawValue, selector: #selector(keyboardDidShow))
        subscribeToNotification(NSNotification.Name.UIKeyboardDidHide.rawValue, selector: #selector(keyboardDidHide))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    @IBAction func getLocation(_ sender: AnyObject) {     // Preview location on map
        
        guard locationTextField.text != "" else {
            let alert = UIAlertController(title: "Error", message: "Must enter a valid location.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Configure UI
        blueBox.alpha = 0
        mapView.alpha = 1
        mediaLinkView.isHidden = false
        findLocation.isEnabled = false
        findLocation.isHidden = true
        
        topText1.text = ""
        topText2.text = ""
        topText3.text = ""
        
        mediaLinkView.alpha = 1
        linkTextField.isHidden = false
        linkTextField.isEnabled = true
        
        linkTextField.attributedPlaceholder = NSAttributedString(string: "Enter a Link to Share Here", attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        // Start activity indicator
        self.showActivityIndicator(uiView: mapView)
        
        // Use location to add pin
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationTextField.text!) { (placemarks, error) -> Void in
            guard error == nil else {
                DispatchQueue.main.async(execute: {
                    self.actInd.stopAnimating()
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
                return
            }
            
            guard placemarks!.count > 0 else {
                DispatchQueue.main.async(execute: {
                    self.actInd.stopAnimating()
                    let alert = UIAlertController(title: "Error", message: "Could Not Find Location.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
                return
            }
            
            DispatchQueue.main.async(execute: {
                var emojiString = String()
                self.placemark = MKPlacemark(placemark: placemarks![0])
                self.mapView.addAnnotation(self.placemark)
                let region = MKCoordinateRegionMakeWithDistance(self.placemark.coordinate, 100000, 100000)
                self.mapView.setRegion(region, animated: true)
                let location = self.placemark?.location
                let coordinate = location?.coordinate
                UdacityClient.sharedInstance().tempLatitude = coordinate!.latitude
                UdacityClient.sharedInstance().tempLongitude = coordinate!.longitude
                let countryCode = self.placemark?.isoCountryCode
                
                if countryCode != nil {
                    let base : UInt32 = 127397
                    for v in (countryCode?.unicodeScalars)! {
                        emojiString.unicodeScalars.append(UnicodeScalar(base + v.value)!)
                    }
                } else {
                    emojiString = self.globeEmoji
                }

                UdacityClient.sharedInstance().tempEmoji = emojiString

                // print("Country code is \(countryCode) and emoji is \(emojiString)")
                self.submitButton.isEnabled = true
                self.submitButton.isHidden = false
                self.submitButton.layer.borderWidth = 1
                self.submitButton.layer.borderColor = UIColor.gray.cgColor

            })
            sleep(1)
            self.actInd.stopAnimating()
        }
    }

    @IBAction func submitButtonPressed(_ sender: AnyObject) {
        guard linkTextField.text != "" else {
            let alert = UIAlertController(title: "Error", message: "Must enter a media link.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Udacity Client:  first name, last name stored.  Updated lat, long, media link and emoji
        UdacityClient.sharedInstance().udacityMediaLink = linkTextField.text!
        
        let key = UdacityClient.sharedInstance().udacityKey
        let firstName = UdacityClient.sharedInstance().udacityFirstName
        let lastName = UdacityClient.sharedInstance().udacityLastName
        let mapString = locationTextField.text!
        let mediaURL = UdacityClient.sharedInstance().udacityMediaLink
        let lat = UdacityClient.sharedInstance().tempLatitude
        let long = UdacityClient.sharedInstance().tempLongitude
        let objectID = UdacityClient.sharedInstance().parseObjectID
        var errorOccurred = Bool()
        let jsonBody = NSString(format:
            "{\"uniqueKey\": \"\(key)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(lat), \"longitude\": \(long)}" as NSString)
        
        DispatchQueue.main.async(execute: {

            // Check if user has pin.  If so, pop end of studentBody array to remove previous entry and PUT the student location
            if (UdacityClient.sharedInstance().userHasPin == true) {
                let _ = StudentModel.sharedInstance().studentBody.popLast()
                // put the student location
                UdacityClient.sharedInstance().udacityAddUserPin = 0 // set back to zero to guard against errors giving a new pin

                UdacityClient.sharedInstance().putStudentLocation(jsonBody as AnyObject, objectID: objectID as String) { (results, error) in
                        guard error == nil else  {
                            print("******** HELLO, error is not nil \(error)")
                            errorOccurred = true
                            let putAlert = UIAlertController(title: "Error", message: "Error putting this location.\n\(error! as String)", preferredStyle: UIAlertControllerStyle.alert)
                            putAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                            DispatchQueue.main.async() {
                                self.present(putAlert, animated: true, completion: nil)
                            }
                            return
                            
                        }
                    if (errorOccurred != true) {
                        self.appendStudentBody()
                    }
                    DispatchQueue.main.async() {
                        self.dismiss(animated: true, completion: nil)
                    }

                }
                
            } else {
                // post the student location
                UdacityClient.sharedInstance().postStudentLocation(jsonBody as AnyObject) { (results, error) in
                    print("***** Error in post is \(error)")
                        guard error == nil else {
                            errorOccurred = true
                            let postAlert = UIAlertController(title: "Error", message: "Error posting this location.\n\(error! as String)", preferredStyle: UIAlertControllerStyle.alert)
                            postAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                            DispatchQueue.main.async() {
                                self.present(postAlert, animated: true, completion: nil)
                            }
                            return
                        }
                    if (errorOccurred != true) {
                        self.appendStudentBody()
                    }
                    DispatchQueue.main.async() {
                        self.dismiss(animated: true, completion: nil)
                    }

                }
            }
        }) // end main thread
    }
    
    fileprivate func appendStudentBody() {
        UdacityClient.sharedInstance().udacityAddUserPin = 1  // update flag to include user on the map
        UdacityClient.sharedInstance().udacityEmoji = UdacityClient.sharedInstance().tempEmoji
        UdacityClient.sharedInstance().flagEmoji[UdacityClient.sharedInstance().udacityKey] = UdacityClient.sharedInstance().tempEmoji
        UdacityClient.sharedInstance().udacityLatitude = UdacityClient.sharedInstance().tempLatitude
        UdacityClient.sharedInstance().udcatiyLongitude = UdacityClient.sharedInstance().tempLongitude
        
        StudentModel.sharedInstance().studentBody.append(Student(studentsDictionary : [
            "firstName" : UdacityClient.sharedInstance().udacityFirstName as AnyObject,
            "lastName" : UdacityClient.sharedInstance().udacityLastName as AnyObject,
            "mediaURL": UdacityClient.sharedInstance().udacityMediaLink as AnyObject,
            "uniqueKey" : UdacityClient.sharedInstance().udacityKey as AnyObject,
            "latitude" : UdacityClient.sharedInstance().udacityLatitude as AnyObject,
            "longitude" : UdacityClient.sharedInstance().udcatiyLongitude as AnyObject,
            "locationEmoji" : UdacityClient.sharedInstance().udacityEmoji as AnyObject]))
    }

    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if locationTextField.isFirstResponder == true {
            locationTextField.placeholder = ""
        }
        
        if linkTextField.isFirstResponder == true {
            linkTextField.placeholder = ""
        }
    }
    
    func showActivityIndicator(uiView: UIView) {
        
        actInd.frame = CGRect(x:0.0, y:0.0, width:150.0, height:150.0)
        let x = self.view.frame.size
        let c = x.width
        actInd.center = CGPoint(x: c/2, y: self.view.frame.size.height/3)
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.color = UIColor.black
        
        uiView.addSubview(actInd)
        
        actInd.startAnimating()
        print("Add Pin Activity starts animating ***************")
    }
    

}

// MARK: - LoginViewController: UITextFieldDelegate

extension AddPinViewController {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= 0 // keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += 0 // keyboardHeight(notification)
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    fileprivate func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    fileprivate func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(locationTextField)
        resignIfFirstResponder(linkTextField)
    }
    
    // Udacity Sign Up Button
    @IBAction func UdacitySignUp(_ sender: UIButton) {
        let udacitySignUpURL = Constants.Udacity.UdacitySignUpURL
        UIApplication.shared.openURL(URL(string: udacitySignUpURL)!)
    }
}


// MARK: - LoginViewController (Notifications)

extension AddPinViewController {
    
    fileprivate func subscribeToNotification(_ notification: String, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: notification), object: nil)
    }
    
    fileprivate func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
