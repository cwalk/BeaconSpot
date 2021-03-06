//
//  ViewController.swift
//  BeaconSpot
//
//  Created by Gabriel Theodoropoulos on 10/3/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var btnSwitchSpotting: UIButton!
    
    @IBOutlet weak var lblBeaconReport: UILabel!
    
    @IBOutlet weak var lblBeaconDetails: UILabel!
    
    var beaconRegion: CLBeaconRegion!
    
    var locationManager: CLLocationManager!
    
    var isSearchingForBeacons = false
    
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    
    var lastProximity: CLProximity! = CLProximity.Unknown
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lblBeaconDetails.hidden = true
        btnSwitchSpotting.layer.cornerRadius = 30.0
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let uuid = NSUUID(UUIDString: "48E47A6D-F366-A502-CD5D-1EC12DC66282")
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "com.Clayton.Walker")
        
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: IBAction method implementation
    
    @IBAction func switchSpotting(sender: AnyObject) {
        
        if !isSearchingForBeacons {
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoringForRegion(beaconRegion)
            locationManager.startUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Stop Spotting", forState: UIControlState.Normal)
            lblBeaconReport.text = "Spotting beacons..."
        }
        else {
            locationManager.stopMonitoringForRegion(beaconRegion)
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
            locationManager.stopUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Start Spotting", forState: UIControlState.Normal)
            lblBeaconReport.text = "Not running"
            lblBeaconDetails.hidden = true
        }
        
        isSearchingForBeacons = !isSearchingForBeacons
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        locationManager.requestStateForRegion(region)
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        if state == CLRegionState.Inside {
            locationManager.startRangingBeaconsInRegion(beaconRegion)
        }
        else {
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        lblBeaconReport.text = "Beacon in range"
        lblBeaconDetails.hidden = false
    }
    
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        lblBeaconReport.text = "No beacons in range"
        lblBeaconDetails.hidden = true
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        var shouldHideBeaconDetails = true
        
        if let foundBeacons = beacons {
            if foundBeacons.count > 0 {
                if let closestBeacon = foundBeacons[0] as? CLBeacon {
                    if closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity  {
                        lastFoundBeacon = closestBeacon
                        lastProximity = closestBeacon.proximity
                        
                        var proximityMessage: String!
                        switch lastFoundBeacon.proximity {
                        case CLProximity.Immediate:
                            proximityMessage = "Very close"
                            
                        case CLProximity.Near:
                            proximityMessage = "Near"
                            
                        case CLProximity.Far:
                            proximityMessage = "Far"
                            
                        default:
                            proximityMessage = "Where's the beacon?"
                        }
                        
                        shouldHideBeaconDetails = false
                        
                        lblBeaconDetails.text = "Beacon Details:\nMajor = " + String(closestBeacon.major.intValue) + "\nMinor = " + String(closestBeacon.minor.intValue) + "\nDistance: " + proximityMessage
                    }
                }
            }
        }
        
        lblBeaconDetails.hidden = shouldHideBeaconDetails
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
    
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        println(error)
    }
    
    
    func locationManager(manager: CLLocationManager!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
        println(error)
    }
    

}

