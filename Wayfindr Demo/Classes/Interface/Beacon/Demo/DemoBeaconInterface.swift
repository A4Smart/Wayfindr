//
//  DemoBeaconInterface.swift
//  Wayfindr Demo
//
//  Created by Wayfindr on 21/12/2015.
//  Copyright © 2015 Wayfindr.org Limited. All rights reserved.
//

import Foundation
import UIKit

final class DemoBeaconInterface: NSObject, BeaconInterface, ESTBeaconManagerDelegate {
    
    // MARK: - Properties
    
    var needsFullBeaconData = false
    
    var monitorBeacons = true
    
    weak var delegate: BeaconInterfaceDelegate?
    
    weak var stateDelegate: BeaconInterfaceStateDelegate?

    /// List of valid beacons that the `BeaconInterface` use for filtering.
    ///     If `nil` then the `BeaconInterface` should parse all beacons.
    var validBeacons: [BeaconIdentifier]?
    
    fileprivate(set) var interfaceState = BeaconInterfaceState.initializing {
        didSet {
            stateDelegate?.beaconInterface(self, didChangeState: interfaceState)
        }
    }
    
    // API Key used by Beacon manufacturer
    fileprivate let apiKey: String
    
    //GIACOMO
    let beaconManager = ESTBeaconManager()
    let locationManager = CLLocationManager()
    
    let beaconRegion = CLBeaconRegion(
        proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,  /*major: 200,*/
        identifier: "ranged region")
    let sanMarco = CLBeaconRegion(
        proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major:10000,
        identifier: "san marco")
    
    // MARK: - Initializers
    
    init(apiKey: String, monitorBeacons: Bool = true) {
        self.apiKey = apiKey
        
        super.init()
 
        // Perform Beacon SDK specific setup here
        // Update interfaceState property once it is setup or setup has failed
        
        //GIACOMO
        self.beaconManager.delegate = self
        // 4. We need to request this authorization for every beacon manager
        self.beaconManager.requestAlwaysAuthorization()
        
        let defaults = UserDefaults.standard
        let MostraSoloSanMarco = defaults.bool(forKey: WAYDeveloperSettings.WAYDeveloperSettingsKeys.MostraSoloPiazzaButton)
        
        if MostraSoloSanMarco {
            self.beaconManager.startRangingBeacons(in: self.sanMarco)
        }
        else{
            self.beaconManager.startRangingBeacons(in: self.beaconRegion)
        }
        //END GIACOMO
        
        // Fetch currently known Beacons using SDK specific methods here
        // Create new WAYBeacon instances for each beacon returned by the Beacon SDK
        
        interfaceState = .operating
        
    }

    
    // MARK: - GET
    
    //LETTURA SEGNALE BEACON
    func beaconManager( _ manager: Any, didRangeBeacons beacons: [CLBeacon],
                       in region: CLBeaconRegion) {
        //LETTURA OGGETTI BEACON DA API ESTIMOTE
        //viene ricreato un array di beacon, ordinati per rssi( credo, forse per accuracy)
        guard let myBeacons = beacons as? [CLBeacon] else {
            return
        }
        let filteredSortedBeacons = myBeacons.filter({
            beacon in
            
            let proximity = beacon.proximity != CLProximity.unknown
            let accuracy = beacon.accuracy >= 0.0
            let major = beacon.major != nil
            let minor = beacon.minor != nil
            
            return proximity && accuracy && major && minor
            
        }).sorted(by: {$0.accuracy < $1.accuracy})
        
        guard !filteredSortedBeacons.isEmpty else {
            return
        }
        
        let validatedBeacons: [CLBeacon]
        if let myValidBeacons = validBeacons {
            validatedBeacons = filteredSortedBeacons.filter({
                let beaconID = BeaconIdentifier(major: Int($0.major), minor: Int($0.minor))
                
                return myValidBeacons.contains(beaconID)
            })
        } else {
            validatedBeacons = filteredSortedBeacons
        }
        
        //DEFINIZIONE ARRAY DI WAYBEACON
        //qui viene creato l'oggetto WAYBeacon per ciascun beacon trovato
        var foundBeacons = [WAYBeacon]()
        for beacon in validatedBeacons {
            //let newBeacon = WAYBeacon(beacon: beacon) era così
            let newBeacon = WAYBeacon(beacon: beacon, advertisingInterval: nil, batteryLevel: nil, lastUpdated: nil, shortID: nil, txPower: nil)

            foundBeacons.append(newBeacon)
        }
        
        if !foundBeacons.isEmpty {
            delegate?.beaconInterface(self, didChangeBeacons: foundBeacons)
        }

    }
    
    //END GIACOMO
    
    func getBeacons(completionHandler: ((Bool, [WAYBeacon]?, BeaconInterfaceAPIError?) -> Void)?) {
        
        completionHandler?(true, [WAYBeacon](), nil)
    }

}

