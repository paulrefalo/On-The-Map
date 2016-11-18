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
        
        self.getStudentData()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.removeUserPin()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if (UdacityClient.sharedInstance().udacityAddUserPin == 1) {
            self.includeUserPin()
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
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
    
    func removeUserPin() {
        // Remove user's pin from the map
        dispatch_async(dispatch_get_main_queue()) {
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
    
    @IBAction func reloadButton(sender: AnyObject) {
        UdacityClient.sharedInstance().studentBody.removeAll()
        UdacityClient.sharedInstance().userHasPin = false
        UdacityClient.sharedInstance().udacityAddUserPin = 0
        self.getStudentData()
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView : MKMapView, annotationView view : MKAnnotationView, calloutAccessoryControlTapped control : UIControl) {
        print("In annotation webview call")
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let urlToOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: urlToOpen)!)
                print("In control block and urlToOpen is \(urlToOpen)")
            }
        }
    }
    
    func addAnnotations() {
        print("Add annotations called")

        var annotations = [MKPointAnnotation]()
        for student in UdacityClient.sharedInstance().studentBody {
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
        
        dispatch_async(dispatch_get_main_queue()) {
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
        
    private func getStudentData() {
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
                }
                
            }
        }
    }

}
