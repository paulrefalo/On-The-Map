//
//  MapViewController.swift
//  On The Map
//
//  Created by Paul ReFalo on 10/24/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.showActivityIndicator(uiView: mapView)
        self.getStudentData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.removeUserPin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (UdacityClient.sharedInstance().udacityAddUserPin == 1) {
            self.includeUserPin()
        }
    }
    
    // Views
    @IBOutlet weak var mapView: MKMapView!
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()

    
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
    
    func removeUserPin() {
        // Remove user's pin from the map
        DispatchQueue.main.async {
            let name = UdacityClient.sharedInstance().udacityFirstName + " " + UdacityClient.sharedInstance().udacityLastName
            let allAnnotations = self.mapView.annotations
            for annotation in allAnnotations {
                if let title = annotation.title! as String! {
                    if title == name {
                        self.mapView.removeAnnotation(annotation)
                        print("Pin removed")
                    }
                }
            }
        }
    }
    @IBAction func logoutPressed(_ sender: Any) {
        StudentModel.sharedInstance().studentBody.removeAll()
        UdacityClient.sharedInstance().userHasPin = false
        UdacityClient.sharedInstance().udacityAddUserPin = 0
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "loginViewController")
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func showActivityIndicator(uiView: UIView) {

        actInd.frame = CGRect(x:0.0, y:0.0, width:150.0, height:150.0)
        actInd.center = uiView.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.color = UIColor.black

        uiView.addSubview(actInd)
        
        actInd.startAnimating()
        print("Activity starts animating")
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView : MKMapView, annotationView view : MKAnnotationView, calloutAccessoryControlTapped control : UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let urlToOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: urlToOpen)!)
            }
        }
    }
    
    func addAnnotations() {
        print("Add annotations called")

        var annotations = [MKPointAnnotation]()
        for student in StudentModel.sharedInstance().studentBody {
            let annotation = MKPointAnnotation()
            let nameString = student.firstName + " " + student.lastName
            annotation.title = nameString
            annotation.subtitle = student.mediaURL
            annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    func includeUserPin() {
        let lat = UdacityClient.sharedInstance().udacityLatitude
        let long = UdacityClient.sharedInstance().udcatiyLongitude
        print("Include User Pin called")
        
        DispatchQueue.main.async {
            // Center the map
            let location = CLLocationCoordinate2DMake(lat, long)
            let span = MKCoordinateSpanMake(50, 60)
            let region = MKCoordinateRegion(center: location, span: span)
            self.mapView.setRegion(region, animated: true)
            
            let userAnnotation = MKPointAnnotation()
            userAnnotation.title = UdacityClient.sharedInstance().udacityFirstName + " " + UdacityClient.sharedInstance().udacityLastName
            userAnnotation.subtitle = UdacityClient.sharedInstance().udacityMediaLink
            userAnnotation.coordinate = CLLocationCoordinate2DMake(lat, long)
            
            self.mapView.addAnnotation(userAnnotation)
            UdacityClient.sharedInstance().userHasPin = true
        }
        
    }
        
    func getStudentData() {

        let requestString = "https://parse.udacity.com/parse/classes/StudentLocation"
        // let _ = Int(arc4random_uniform(200)) // used for skipping around randomly
        UdacityClient.sharedInstance().getStudentData(requestString, limit : 100, skip : 0) { (results, error) in
            if error != nil {
                print("Error block in getStudentData")
                self.actInd.stopAnimating()

                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                DispatchQueue.main.async {
                    
                    // Success getting user data
                    let allAnnotations = self.mapView.annotations
                    self.mapView.removeAnnotations(allAnnotations)
                    // Center the map
                    let location = CLLocationCoordinate2D(
                        latitude: 30.000000,
                        longitude: -95.000000
                    )
                    let span = MKCoordinateSpanMake(50, 60)
                    let region = MKCoordinateRegion(center: location, span: span)
                    self.mapView.setRegion(region, animated: true)
                    
                    self.addAnnotations()
                    // sleep(3)
                    self.actInd.stopAnimating()
                }
                
            }
        }
    }

}
