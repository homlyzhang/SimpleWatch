//
//  InterfaceController.swift
//  SimpleWatch WatchKit Extension
//
//  Created by Homly ZHANG on 3/11/2016.
//  Copyright © 2016 Homly ZHANG. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import CoreLocation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    // MARK: Properties

    let cmManager = CMMotionManager()
    let clManager = CLLocationManager()
    var session: WCSession?
    var accelerationData = [NSDate : CMAcceleration]()
    var rotationRateData = [NSDate : CMRotationRate]()
    var locationData = [NSDate : CLLocation]()
    var deviceMotionData = [NSDate : CMDeviceMotion]()
    let convertTool = ConvertTool()
    let COLLECT_FREQUENCY = 10.0
    let SEND_FREQUNCY = 0.5
    var count = 0.000

    // MARK: initialzation

    func initWCSession() {
        if WCSession.isSupported() {
            session = WCSession.default()
//            print("session: \(session), ")
//            print("session!.delegate: \(session!.delegate)")
            session!.delegate = self
            session!.activate()
        }
    }

    func initSensorRecorder() {
        NSLog("isAccelerometerRecordingAvailable: " + CMSensorRecorder.isAccelerometerRecordingAvailable().description)
        if CMSensorRecorder.isAccelerometerRecordingAvailable() {
            NSLog("isAuthorizedForRecording: " + CMSensorRecorder.isAuthorizedForRecording().description)
            if CMSensorRecorder.isAuthorizedForRecording() {
                let recorder = CMSensorRecorder()
                recorder.recordAccelerometer(forDuration: 5)
            }
        }
    }

    func initAccelerometer(_ timeInterval: Double) {
        cmManager.startAccelerometerUpdates()
        Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.updateAccelerometer), userInfo: nil, repeats: true)
    }

    func initGyro(_ timeInterval: Double) {
        cmManager.startGyroUpdates()
        Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.updateGyro), userInfo: nil, repeats: true)
    }

    func initDeviceMotion(_ timeInterval: Double) {
        cmManager.startDeviceMotionUpdates()
        Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.updateDeviceMotion), userInfo: nil, repeats: true)
    }

    func initLocation(_ timeInterval: Double) {
        clManager.delegate = self
        clManager.startUpdatingLocation()
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined {
            clManager.requestAlwaysAuthorization()
        }
        Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.updateLocation), userInfo: nil, repeats: true)
    }

    override func awake(withContext context: Any?) {
        NSLog("awake")
        super.awake(withContext: context)

        // Configure interface objects here.
        initWCSession()
        initSensorRecorder()

//        NSLog("isAccelerometerAvailable: \(cmManager.isAccelerometerAvailable), isGyroAvailable: \(cmManager.isGyroAvailable), gyroData: \(cmManager.gyroData), isMagnetometerAvailable: \(cmManager.isMagnetometerAvailable), isDeviceMotionAvailable: \(cmManager.isDeviceMotionAvailable)")
        let collectTimeInterval = 1.0 / COLLECT_FREQUENCY
//        initAccelerometer(collectTimeInterval)
//        initGyro(collectTimeInterval)
        initDeviceMotion(collectTimeInterval)
        initLocation(collectTimeInterval)
    }

    // MARK: function

    func sendData() {
//        NSLog("sendData")
        let collectThreshold = Int(COLLECT_FREQUENCY / SEND_FREQUNCY)
        let data: [String : Any]?

        if deviceMotionData.count >= collectThreshold || locationData.count >= collectThreshold {
            data = convertTool.makeSendMessage(deviceMotions: deviceMotionData, locations: locationData)
            deviceMotionData.removeAll()
            locationData.removeAll()
        } else if accelerationData.count >= collectThreshold || rotationRateData.count >= collectThreshold || locationData.count >= collectThreshold {
            data = convertTool.makeSendMessage(accelerations: accelerationData, rotationRates: rotationRateData, locations: locationData)
            accelerationData.removeAll()
            rotationRateData.removeAll()
            locationData.removeAll()
        } else {
            data = nil
        }

        if data != nil {
//            NSLog("sendMessage")
            session!.sendMessage(data!, replyHandler: nil, errorHandler: nil)

        }
    }

    func updateAccelerometer() {
        // for simulator - start
//        count += 0.001
//        accelerationData[NSDate()] = CMAcceleration(x: count, y: 0, z: 0)
//        sendData()
        // for simulator - end

//        NSLog("isAccelerometerActive: \(cmManager.isAccelerometerActive), isAccelerometerAvailable: \(cmManager.isAccelerometerAvailable)")
        if cmManager.isAccelerometerActive && cmManager.isAccelerometerAvailable {
            let accelerometerData = cmManager.accelerometerData
            if accelerometerData != nil {
                let acceleration = (accelerometerData?.acceleration)!
//                NSLog("acceleration: " + acceleration.debugDescription)
//                let accStr = "acceleration: (\(acceleration.x.format(".3")), \(acceleration.y.format(".3")), \(acceleration.z.format(".3")))"
//                print(accStr)
//                NSLog(accStr)
                accelerationData[NSDate()] = acceleration
                sendData()
            }
        }
    }

    func updateGyro() {
        // for simulator - start
//        count += 0.001
//        rotationRateData[NSDate()] = CMRotationRate(x: count, y: 0, z: 0)
//        sendData()
        // for simulator - end

//        NSLog("isGyroActive: \(cmManager.isGyroActive), isGyroAvailable: \(cmManager.isGyroAvailable), gyroData: \(cmManager.gyroData)")
        if cmManager.isGyroActive && cmManager.isGyroAvailable {
            let dataOptional = cmManager.gyroData
            if dataOptional != nil {
                let meter = dataOptional!.rotationRate
//                let str = "rotationRate: (\(meter.x.format(".3")), \(meter.y.format(".3")), \(meter.z.format(".3")))"
//                print(str)
//                NSLog(str)
                rotationRateData[NSDate()] = meter
                sendData()
            }
        }
    }

    func updateDeviceMotion() {
        // for simulator - start
//        count += 0.001
//        rotationRateData[NSDate()] = CMRotationRate(x: count, y: 0, z: 0)
//        sendData()
        // for simulator - end

//        NSLog("isDeviceMotionActive: \(cmManager.isDeviceMotionActive), isDeviceMotionAvailable: \(cmManager.isDeviceMotionAvailable), deviceMotion: \(cmManager.deviceMotion)")
        if cmManager.isDeviceMotionActive && cmManager.isDeviceMotionAvailable {
            let dataOptional = cmManager.deviceMotion
            if dataOptional != nil {
                let meter = dataOptional!
//                let str = "rotationRate: (\(meter.rotationRate.x.format(".3")), \(meter.rotationRate.y.format(".3")), \(meter.rotationRate.z.format(".3")))"
//                print(str)
//                NSLog(str)
                deviceMotionData[NSDate()] = meter
                sendData()
            }
        }
    }

    func updateLocation() {
        // for simulator - start
//        count += 0.00001
//        locationData[NSDate()] = CLLocation(latitude: count, longitude: count)
//        sendData()
        // for simulator - end

        let authorizationStatusAllow = CLLocationManager.authorizationStatus() != CLAuthorizationStatus.restricted && CLLocationManager.authorizationStatus() != CLAuthorizationStatus.denied
        let locationServicesEnabled = CLLocationManager.locationServicesEnabled()
//        NSLog("authorizationStatus: \(CLLocationManager.authorizationStatus()), authorizationStatusAllow: \(authorizationStatusAllow), locationServicesEnabled: \(locationServicesEnabled), location: \(clManager.location)")
        if authorizationStatusAllow && locationServicesEnabled {
            let dataOptional = clManager.location
            if dataOptional != nil {
                let meter = dataOptional!
//                let str = "location: (\(meter.coordinate.longitude.format(".3")), \(meter.coordinate.latitude.format(".3")), \(meter.altitude.format(".3")))"
//                print(str)
//                NSLog(str)
                locationData[NSDate()] = meter
                sendData()
            }
        }
    }

    override func willActivate() {
        NSLog("willActivate")
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        NSLog("didDeactivate")
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}


extension InterfaceController: WCSessionDelegate {
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
}

extension InterfaceController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        NSLog("didUpdateLocations")
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        NSLog("didFailWithError: \(error)")
    }
}

extension Double {
    func format(_ f: String) -> String {
        var result = self >= 0 ? "+" : ""
        result += String(format: "%\(f)f", self)
        return result
    }
}
