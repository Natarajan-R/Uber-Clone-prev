//
//  RiderViewController.swift
//  UberAlles
//
//  Created by Julian Nicholls on 18/09/2015.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation

class RiderViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()

    var userLat:  CLLocationDegrees = 0.0
    var userLong: CLLocationDegrees = 0.0

    var requestActive = false

    @IBOutlet weak var map: MKMapView!

    @IBOutlet weak var callButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

//        print("Setting up locationManager")

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

//        print("Called startUpdating")
    }


    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("Updated")
        
        let location = locations[0].coordinate

        userLat     = location.latitude
        userLong    = location.longitude

        self.setMapCentre(userLat, long: userLong)

//        self.locationManager.stopUpdatingLocation()
    }

    func setMapCentre(lat: Double, long: Double) -> Void {
        let centre = CLLocationCoordinate2DMake(lat, long)

        let dLat:  CLLocationDegrees = 0.007
        let dLong: CLLocationDegrees = 0.007
        let span:  MKCoordinateSpan  = MKCoordinateSpanMake(dLat, dLong)

        let region: MKCoordinateRegion = MKCoordinateRegionMake(centre, span)

        map.setRegion(region, animated: true)

        if map.annotations.count == 0 ||
           map.annotations[0].coordinate.latitude != lat ||
           map.annotations[0].coordinate.longitude != long {
            map.removeAnnotations(map.annotations)

            let pin = MKPointAnnotation()
            pin.coordinate = centre
            pin.title = "Your Location"
            map.addAnnotation(pin)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logoutRider" {
            PFUser.logOut()
        }
    }

    @IBAction func callPressed(sender: AnyObject) {
        if requestActive {
            let query = PFQuery(className: "RiderRequest")

            query.whereKey("username", equalTo: PFUser.currentUser()!.username!)

            query.findObjectsInBackgroundWithBlock({
                (objects, error) -> Void in

                if error == nil {
                    for object in objects! {
                        object.deleteInBackground()
                    }
                }
                else {
                    print(error!.localizedDescription)
                }
            })

            callButton.setTitle("Call an Über", forState: .Normal)
            requestActive = false
        }
        else {
            let request = PFObject(className: "RiderRequest")
            request["username"] = PFUser.currentUser()!.username
            request["location"] = PFGeoPoint(latitude: userLat, longitude: userLong)

            request.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in

                if success {
                    self.callButton.setTitle("Cancel Über", forState: .Normal)
                    self.requestActive = true
                } else {
                    let errorMessage = error?.localizedDescription

                    let alert = UIAlertController(title: "Could not call Über", message: errorMessage! + "\nPlease try again", preferredStyle: .Alert)

                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
                        (action) -> Void in

                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
