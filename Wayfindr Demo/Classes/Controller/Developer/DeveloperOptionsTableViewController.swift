//
//  DeveloperOptionsTableViewController.swift
//  Wayfindr Demo
//
//  Created by Wayfindr on 30/11/2015.
//  Copyright (c) 2016 Wayfindr (http://www.wayfindr.net)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights 
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
//  copies of the Software, and to permit persons to whom the Software is furnished
//  to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all 
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

/// Table view for viewing and adjusting developer/tester settings.
final class DeveloperOptionsTableViewController: UITableViewController, UITextFieldDelegate {
    
    fileprivate var compassAccuracy : Double = WAYConstants.Bussola.startingTolerance
    
    // MARK: - Types
    
    /// List of options to show the user.
    fileprivate enum DeveloperOptions: Int {
        case showForceNext
        case showRepeatInAccessibility
        case soloPiazzaSanMarco //GIACOMO
        case usaBussola
        
        static let allValues = [showForceNext, showRepeatInAccessibility, soloPiazzaSanMarco, usaBussola]
    }
    
    
    // MARK: - Properties
    
    /// Reuse identifier for the table cells.
    fileprivate let reuseIdentifier = "OptionCell"
    fileprivate let labelIdentifier = "LabelCell"

    
    // MARK: - Initializers
    
    init() {
        super.init(style: .grouped)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(LabelTableViewCell.self, forCellReuseIdentifier: labelIdentifier)
        tableView.estimatedRowHeight = WAYConstants.WAYSizes.EstimatedCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        title = WAYStrings.CommonStrings.DeveloperOptions
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DeveloperOptions.allValues.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.item < DeveloperOptions.allValues.count){
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            
            if let switchCell = cell as? SwitchTableViewCell {
                if let selectedOption = DeveloperOptions(rawValue: indexPath.row) {
                    switch selectedOption {
                    case .showForceNext:
                        switchCell.textLabel?.text = WAYStrings.DeveloperOptions.ShowForceNextButton
                    
                        switchCell.switchControl.isOn = WAYDeveloperSettings.sharedInstance.showForceNextButton
                    case .showRepeatInAccessibility:
                        switchCell.textLabel?.text = WAYStrings.DeveloperOptions.ShowRepeatButton
                    
                        switchCell.switchControl.isOn = WAYDeveloperSettings.sharedInstance.showRepeatButton
                    case .soloPiazzaSanMarco:
                        switchCell.textLabel?.text = WAYStrings.DeveloperOptions.ShowSoloPiazza
                        
                        switchCell.switchControl.isOn = WAYDeveloperSettings.sharedInstance.showPiazzaButton
                    case .usaBussola:
                        switchCell.textLabel?.text = WAYStrings.DeveloperOptions.ShowUsaBussola
                        
                        switchCell.switchControl.isOn = WAYDeveloperSettings.sharedInstance.showBussolaButton
                    }
                }
            
                switchCell.textLabel?.numberOfLines = 0
                switchCell.textLabel?.lineBreakMode = .byWordWrapping
            
                switchCell.switchControl.addTarget(self, action: #selector(DeveloperOptionsTableViewController.switchValueChanged(_:)), for: .valueChanged)
                switchCell.switchControl.tag = indexPath.row
            }
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: labelIdentifier, for: indexPath)
            if let labelCell = cell as? LabelTableViewCell {
                labelCell.textLabel?.text = "Angolo tolleranza bussola (0-90): "
                labelCell.textLabel?.numberOfLines = 0
                labelCell.textLabel?.lineBreakMode = .byWordWrapping
                
                //LEGGO IL VALORE DALLA MEMORIA
                let defaults = UserDefaults.standard
                let accuracySalvata = defaults.double(forKey: WAYStrings.defaultsKeys.compassKey)
                if(accuracySalvata>0 && accuracySalvata<90){
                    labelCell.textControl.placeholder = accuracySalvata.description
                    compassAccuracy = accuracySalvata
                }
                else{
                    labelCell.textControl.placeholder = compassAccuracy.description
                }
                
                labelCell.textControl.delegate = self
            }
            
            return cell
        }
        
        //return cell
    }
    
    //TEXTFIELD DELEGATE
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("TextField did begin editing method called")
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("TextField did end editing method called \(textField.text!)")
        
        if let textNumber = NumberFormatter().number(from: textField.text!) {
            if(textNumber.floatValue>=0 && textNumber.doubleValue<=90){
                compassAccuracy = textNumber.doubleValue
                textField.text = compassAccuracy.description
                //SALVO IL VALORE IN MEMORIA
                let defaults = UserDefaults.standard
                defaults.set(compassAccuracy, forKey: WAYStrings.defaultsKeys.compassKey)
            }
            else{
                textField.text = compassAccuracy.description
            }
        }
        else{
            textField.text = compassAccuracy.description
        }
        
        return
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("TextField should begin editing method called")
        return true;
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("TextField should clear method called")
        return true;
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("TextField should end editing method called")
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("While entering the characters this method gets called")
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder();
        return true;
    }
    //END TEXTFIELD DELEGATE

    
    // MARK: - Control Actions
    
    /**
    Action when the user flips a switch.
    
    - parameter sender: `UISwitch` that changed value.
    */
    func switchValueChanged(_ sender: UISwitch) {
        if let selectedOption = DeveloperOptions(rawValue: sender.tag) {
            switch selectedOption {
            case .showForceNext:
                WAYDeveloperSettings.sharedInstance.showForceNextButton = sender.isOn
            case .showRepeatInAccessibility:
                WAYDeveloperSettings.sharedInstance.showRepeatButton = sender.isOn
            case .soloPiazzaSanMarco:
                WAYDeveloperSettings.sharedInstance.showPiazzaButton = sender.isOn
            case .usaBussola:
                WAYDeveloperSettings.sharedInstance.showBussolaButton = sender.isOn
            }
        }
    }
    
}
