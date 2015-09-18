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

class RiderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
}
