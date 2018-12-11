//
//  ValoriRssiBeaconExport.swift
//  Wayfindr Demo
//
//  Created by Handing  on 01/02/18.
//  Copyright © 2018 Wayfindr.org Limited. All rights reserved.
//

import UIKit

final class RssiExportViewController: BaseViewController<BeaconExportView>, BeaconInterfaceDelegate {
    
    // MARK: - Properties
    
    /// Interface for interacting with beacons.
    private var interface: BeaconInterface
    
    /// Beacon data to save in table.
    fileprivate var mybeacons = [WAYBeacon]()
    
    fileprivate var stringToPrint = ""
    fileprivate var numeroNodo = 1;

    // MARK: - Intiailizers / Deinitializers
    
    init(interface: BeaconInterface) {
        self.interface = interface
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //title = WAYStrings.ActiveRoute.ActiveRoute
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        interface.delegate = self
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        interface.delegate = nil
    }

    
    override func setupView() {
        super.setupView()
        
        underlyingView.exportButton.addTarget(self, action: #selector(RssiExportViewController.exportNodeButtonPressed(_:)), for: .touchUpInside)
        underlyingView.insertPointOfInterest.addTarget(self, action: #selector(RssiExportViewController.savePOI(_:)), for: .touchUpInside)
    }
    
    func beaconInterface(_ beaconInterface: BeaconInterface, didChangeBeacons beacons: [WAYBeacon]) {
        if !mybeacons.isEmpty{
            mybeacons.removeAll()
        }
        
        for value in beacons{
            mybeacons.append(value)
        }
        
    }
    
    // Control buttons
    
    func exportNodeButtonPressed(_ sender: UIButton) {
        
        let csvHeader = generateHeader()
        let csvString = csvHeader + stringToPrint
        
        exportCSV(csvString, filePrefix: "valori_rssi", sourceView: sender)
        stringToPrint.removeAll()
        numeroNodo = 1
    }
    
    func savePOI(_ sender: UIButton) {
        let stringToAdd = generateCsvString()
        stringToPrint += stringToAdd
        
        numeroNodo += 1
    }
    
    // MARK: - Export CSV
    
    fileprivate func exportCSV(_ csvString: String, filePrefix: String, sourceView: UIView) {
        guard let tmpDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            displayExportError()
            print("Error fetching temp directory.")
            return
        }
        
        let tmpDirectoryURL = URL(fileURLWithPath: tmpDirectory, isDirectory: true)
        let fileURL = tmpDirectoryURL.appendingPathComponent("\(filePrefix)_export.csv", isDirectory: false)
        
        guard let csvData = csvString.data(using: String.Encoding.utf16) else {
            displayExportError()
            print("Error encoding data.")
            return
        }
        
        guard (try? csvData.write(to: fileURL, options: [.atomic])) != nil else {
            displayExportError()
            print("Error writing file.")
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = sourceView
        present(activityController, animated: true, completion: nil)
    }
    
    fileprivate func displayExportError() {
        displayError(title: WAYStrings.CommonStrings.Error, message: "There was an error exporting your data. Please try again.")
    }
    
    //DEFINIZIONE INTESTAZIONE COLONNE
    func generateHeader() -> String {
        //Headers tabella
        let ValueKeys: [String] = ["NODO", "MAJOR", "MINOR", "ACCURACY", "RSSI"]
        
        var BeaconCsvHeaders = ""
        let separator = ","
        let endLine = "\n"
        
        for value in ValueKeys{
            if !BeaconCsvHeaders.isEmpty { BeaconCsvHeaders += separator }
            
            BeaconCsvHeaders += value
        }
        BeaconCsvHeaders += endLine
        //End Headers tabella
        
        return BeaconCsvHeaders

    }
    
    //GENERA STRINGA CON VALORI DEI BEACON OGNI VOLTA CHE SI PREME IL TASTO SOTTO
    func generateCsvString() -> String {
        //Valori Tabella
        var BeaconData = ""
        let separator = ","
        let endLine = "\n"
        
        for beac in mybeacons{
            let myAccuracy = beac.accuracy?.description
            let myRssi = beac.rssi?.description
            
            let str = "\(numeroNodo),\(beac.major),\(beac.minor),"
            BeaconData += str + myAccuracy! + separator + myRssi! + endLine
        }
        
        return BeaconData + endLine + endLine
    }

    
}

