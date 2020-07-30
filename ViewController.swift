//
//  ViewController.swift
//  CoreLocationDemo
//
//  Created by Eyasu Woldu on 4/23/20.
//  Copyright © 2020 Memhir. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    let motionActivityManager = CMMotionActivityManager()
    let pedometerManager = CMPedometer()
    let emojiLabel = UILabel(frame: CGRect(x: 400, y: 500, width: 150, height: 150))
    var wordToLookup: String?
    
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance: Double = 0
    var speed: Double = 0
    
    
    // UI
    @IBOutlet weak var automotiveLabel: UILabel!
    
    @IBOutlet weak var cyclingLabel: UILabel!
    
    @IBOutlet weak var runningLabel: UILabel!
    
    @IBOutlet weak var walkingLabel: UILabel!
    
    @IBOutlet weak var stationaryLabel: UILabel!
    
    @IBOutlet weak var motionconfidenceLabel: UILabel!
    
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    
    // this is like the main function that runs everything
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orange
        // Do any additional setup after loading the view.
        setupLocationManager()
        setupActivityManager()
//        setupMotionManager()
    }
    
    // ask user for location authorization
    func setupLocationManager() {
        locationManager.delegate = self
        // accuracy of location tracker (used for measuring distance)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    
    }
    
    // make sure user device is supported
    func setupActivityManager() {
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivityType()
        }
        else {
            self.automotiveLabel.text = "🚫"
            self.cyclingLabel.text = "🚫"
            self.runningLabel.text = "🚫"
            self.walkingLabel.text = "🚫"
            self.stationaryLabel.text = "🚫"
            print("Motion tracking is not supported for this device")
        }
    }
    
    // this is for accelrometer and pedometer, unfortunatly our device (iPad) does not support pedometer.
    // We decided not to use accelerometer in the final stages of our development
    func setupMotionManager() {
        if self.motionManager.isAccelerometerAvailable {
            startTrackingAccelerometer()
        }
        else {
            print("accelerometer not available on this device")
        }
        if CMPedometer.isDistanceAvailable() && CMPedometer.isStepCountingAvailable() {
            startPedometer()
        }
        else {
            print("pedometer not available not available on this device")
        }
    }
    
    func startPedometer() {
        self.pedometerManager.startUpdates(from: Date()) { (pedometer, error) in
            pedometer?.averageActivePace?.doubleValue
            print(pedometer?.averageActivePace?.doubleValue)
        }
    
    }
    
    func startTrackingAccelerometer() {
        self.motionManager.accelerometerUpdateInterval = 0.10
        var t = 0
        var ax: Double?
        var ay: Double?
        var az: Double?
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
            ax = data?.acceleration.x.truncate(places: 3)
            ay = data?.acceleration.y.truncate(places: 3)
            az = data?.acceleration.z.truncate(places: 3)
            print(t, ax, ay, az)
            t+=1
        }
    }
    
    // detect user activity type
    func startTrackingActivityType() {
        motionActivityManager.startActivityUpdates(to: .main) { (activity) in
            guard let activity = activity else {
                return
            }
            
            var modes: Set<String> = []
            self.walkingLabel.text = "🚶‍"
            self.runningLabel.text = "🏃‍"
             self.automotiveLabel.text = "🚗"
            self.cyclingLabel.text = "🚴‍"
            self.stationaryLabel.text = "🧍"
//            if activity.walking {
//                modes.insert("🚶‍")
//                print("walking")
//                self.walkingLabel.text = "🚶‍"
//            } else { self.walkingLabel.text = " "}
//
//            if activity.running {
//                modes.insert("🏃‍")
//                print("running")
//                self.runningLabel.text = "🏃‍"
//            } else { self.runningLabel.text = " "}
//
//
//            if activity.cycling {
//                modes.insert("🚴‍")
//                print("biking")
//                self.cyclingLabel.text = "🚴‍"
//            } else { self.cyclingLabel.text = " "}
//
//            if activity.automotive {
//                modes.insert("🚗")
//                print("driving")
//                self.automotiveLabel.text = "🚗"
//            } else { self.automotiveLabel.text = " "}
//
//            if activity.stationary {
//                modes.insert("🧍")
//                print("stationary")
//                self.stationaryLabel.text = "🧍"
//            } else { self.stationaryLabel.text = " "}
//
//            if activity.unknown {
//                modes.insert("❔")
//                print("unknown stance")
//                self.automotiveLabel.text = "❔"
//                self.cyclingLabel.text = "❔"
//                self.runningLabel.text = "❔"
//                self.walkingLabel.text = "❔"
//                self.stationaryLabel.text = "❔"
//            }
            
            if activity.confidence == CMMotionActivityConfidence.high {
                self.motionconfidenceLabel.text = "🟢"
                print("🟢")
            }
            else if activity.confidence == CMMotionActivityConfidence.medium {
                self.motionconfidenceLabel.text = "🟡"
                print("🟡")
            }
            else if activity.confidence == CMMotionActivityConfidence.low {
                self.motionconfidenceLabel.text = "🔴"
                print("🔴")
            }

            print(modes.joined(separator: ", "))
        }
    }
    
    // location tracking
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        var curr_distance = 0.0
        
        if self.startLocation == nil {
            self.startLocation = locations.first! as CLLocation
        } else {
            let lastLocation = locations.last! as CLLocation
            let distance = self.startLocation.distance(from: lastLocation)
            self.startLocation = lastLocation
            self.traveledDistance += distance
            
            curr_distance = self.traveledDistance.truncate(places: 3)
            self.speed = lastLocation.speed
            
            self.distanceLabel.text = "\(curr_distance)"
            self.speedLabel.text = "\(self.speed)"
            
            print("Distance traveled \(curr_distance) m")
        }
        
//        if let location = locations.last {
//            if location.horizontalAccuracy > 0 {
//                locationManager.stopUpdatingLocation()
//
//                let longitude = location.coordinate.longitude
//                let latitude = location.coordinate.latitude
//
//                print("\(latitude), \(longitude)")
//            }
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed, \(error)")
    }
    
    
    
    
}

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}


