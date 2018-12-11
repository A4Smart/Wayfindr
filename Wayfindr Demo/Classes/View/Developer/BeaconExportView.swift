//
//  BeaconExportView.swift
//  Wayfindr Demo
//
//  Created by Handing  on 01/02/18.
//  Copyright © 2018 Wayfindr.org Limited. All rights reserved.
//

import UIKit

final class BeaconExportView: BaseStackView {
    
    
    // MARK: - Properties
    
    let headerLabel = UILabel()
    
    let exportButton              = BorderedButton()
    let insertPointOfInterest     = BorderedButton()
    
    // MARK: - Setup
    
    override func setup() {
        super.setup()
        
        headerLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        headerLabel.lineBreakMode = .byWordWrapping
        headerLabel.numberOfLines = 0
        headerLabel.text = "Salvataggio valori Rssi"
        stackView.addArrangedSubview(headerLabel)
        
        exportButton.setTitle("Salva ed esporta file csv", for: UIControlState())
        stackView.addArrangedSubview(exportButton)
        
        insertPointOfInterest.setTitle("Inserisci POI corrispondente a dove ti trovi", for: UIControlState())
        stackView.addArrangedSubview(insertPointOfInterest)
    }
    
}
