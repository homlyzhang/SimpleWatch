//
//  ViewController.swift
//  SimpleWatch
//
//  Created by Homly ZHANG on 3/11/2016.
//  Copyright © 2016 Homly ZHANG. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import WatchConnectivity

class ViewController: UIViewController {

    // MARK: properties

    @IBOutlet weak var acceX1: UILabel!
    @IBOutlet weak var acceX2: UILabel!
    @IBOutlet weak var acceX3: UILabel!
    @IBOutlet weak var acceY1: UILabel!
    @IBOutlet weak var acceY2: UILabel!
    @IBOutlet weak var acceY3: UILabel!
    @IBOutlet weak var acceZ1: UILabel!
    @IBOutlet weak var acceZ2: UILabel!
    @IBOutlet weak var acceZ3: UILabel!
    @IBOutlet weak var roRateX1: UILabel!
    @IBOutlet weak var roRateX2: UILabel!
    @IBOutlet weak var roRateX3: UILabel!
    @IBOutlet weak var roRateY1: UILabel!
    @IBOutlet weak var roRateY2: UILabel!
    @IBOutlet weak var roRateY3: UILabel!
    @IBOutlet weak var roRateZ1: UILabel!
    @IBOutlet weak var roRateZ2: UILabel!
    @IBOutlet weak var roRateZ3: UILabel!
    @IBOutlet weak var locLongi1: UILabel!
    @IBOutlet weak var locLongi2: UILabel!
    @IBOutlet weak var locLongi3: UILabel!
    @IBOutlet weak var locLati1: UILabel!
    @IBOutlet weak var locLati2: UILabel!
    @IBOutlet weak var locLati3: UILabel!
    @IBOutlet weak var locAlti1: UILabel!
    @IBOutlet weak var locAlti2: UILabel!
    @IBOutlet weak var locAlti3: UILabel!

    let manager = CMMotionManager()
    var session: WCSession?
    let convertTool = ConvertTool()
    let fileTool = FileTool()
    var count = 0

    override func viewDidLoad() {
        NSLog("viewDidLoad")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if WCSession.isSupported() {
            session = WCSession.default()
            session!.delegate = self
            session!.activate()
        }
    }

    func updateAccelerationLabels(_ accelerations: [NSDate : CMAcceleration]) {
        var acce = CMAcceleration()
        let count = Double(accelerations.count)
        for (_, a) in accelerations {
            acce.x += a.x
            acce.y += a.y
            acce.z += a.z
        }
        acce.x /= count
        acce.y /= count
        acce.z /= count
        self.acceX3.text = self.acceX2.text!
        self.acceX2.text = self.acceX1.text!
        self.acceX1.text = acce.x.format(".3")
        self.acceY3.text = self.acceY2.text!
        self.acceY2.text = self.acceY1.text!
        self.acceY1.text = acce.y.format(".3")
        self.acceZ3.text = self.acceZ2.text!
        self.acceZ2.text = self.acceZ1.text!
        self.acceZ1.text = acce.z.format(".3")
    }

    func updateRotationRateLabels(_ rotationRates: [NSDate : CMRotationRate]) {
        var roRate = CMRotationRate()
        let count = Double(rotationRates.count)
        for (_, a) in rotationRates {
            roRate.x += a.x
            roRate.y += a.y
            roRate.z += a.z
        }
        roRate.x /= count
        roRate.y /= count
        roRate.z /= count
        self.roRateX3.text = self.roRateX2.text!
        self.roRateX2.text = self.roRateX1.text!
        self.roRateX1.text = roRate.x.format(".3")
        self.roRateY3.text = self.roRateY2.text!
        self.roRateY2.text = self.roRateY1.text!
        self.roRateY1.text = roRate.y.format(".3")
        self.roRateZ3.text = self.roRateZ2.text!
        self.roRateZ2.text = self.roRateZ1.text!
        self.roRateZ1.text = roRate.z.format(".3")
    }
    
    func updateLocationLabels(_ locations: [NSDate : CLLocation]) {
        var longitude = 0.0
        var latitude = 0.0
        var altitude = 0.0
        let count = Double(locations.count)
        for (_, a) in locations {
            longitude += a.coordinate.longitude
            latitude += a.coordinate.latitude
            altitude += a.altitude
        }
        longitude /= count
        latitude /= count
        altitude /= count
        self.locLongi3.text = self.locLongi2.text!
        self.locLongi2.text = self.locLongi1.text!
        self.locLongi1.text = longitude.format(".3")
        self.locLati3.text = self.locLati2.text!
        self.locLati2.text = self.locLati1.text!
        self.locLati1.text = latitude.format(".3")
        self.locAlti3.text = self.locAlti2.text!
        self.locAlti2.text = self.locAlti1.text!
        self.locAlti1.text = altitude.format(".3")
    }

    func updateLabels(_ watchData: WatchData) {
        DispatchQueue.main.async(execute: {
            self.updateAccelerationLabels(watchData.accelerations)
            self.updateRotationRateLabels(watchData.rotationRates)
            self.updateLocationLabels(watchData.locations)
        })
    }

    override func didReceiveMemoryWarning() {
        NSLog("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: WCSessionDelegate {
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("session")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        NSLog("session:didReceiveMessage")
//        NSLog("\(message)")
        let watchData = WatchData(message)
//        NSLog("\(watchData)")
        updateLabels(watchData)
//        count += 1
        watchData.appendToFile()
//        fileTool.appendTextToFile("\(count)\n")
//        let fileText = fileTool.readFromFile()
//        NSLog(fileText)
//        let acceText = fileTool.readFromFile("20170208_acceleration.txt")
//        print(acceText)
//        let rotationText = fileTool.readFromFile("20170208_rotationRate.txt")
//        print(rotationText)
//        let locationText = fileTool.readFromFile("20170208_location.txt")
//        print(locationText)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        NSLog("session:didReceiveApplicationContext")
//        NSLog("\(applicationContext)")
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        NSLog("session:didReceiveUserInfo")
//        NSLog("\(userInfo)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        NSLog("sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
        NSLog("sessionDidDeactivate")
    }
}

extension Double {
    func format(_ f: String) -> String {
        var result = self >= 0 ? "+" : ""
        result += String(format: "%\(f)f", self)
        return result
    }
}

