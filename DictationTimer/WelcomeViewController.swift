//
//  WelcomeViewController.swift
//  DictationTimer
//
//  Created by Richu on 01/12/18.
//  Copyright © 2018 Srivastava, Richa. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var durationPicker: UIPickerView!
    @IBOutlet weak var countryPicker: UIPickerView!
    var durationData = [("10 Seconds",10), ("20 Seconds",20), ("30 Seconds",30), ("40 Seconds",40), ("50 Seconds",50), ("60 Seconds",60)]
    var countryData = [("English (US)","en-US"), ("English (UK)","en-GB"), ("English (Australian)","en-AU"), ("English (Canadian)","en-CA"), ("Spanish","es-ES"), ("Spanish (Maxican)","es-MX"), ("Spanish (Colombian)","es-CO"), ("French","fr-FR")]
    var selectedDuration = 10
    var selectedCountryCode = "en-US"
    override func viewDidLoad() {
        super.viewDidLoad()
        durationPicker.delegate = self
        durationPicker.dataSource = self
        countryPicker.dataSource = self
        countryPicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == durationPicker {
            return durationData.count
        }else if pickerView == countryPicker {
            return countryData.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == durationPicker {
            return durationData[row].0
        }else if pickerView == countryPicker {
            return countryData[row].0
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == durationPicker {
            selectedDuration = durationData[row].1
        }else if pickerView == countryPicker {
            selectedCountryCode = countryData[row].1
        }
    }
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        var string = ""
//        if pickerView == durationPicker {
//            string = durationData[row].0
//        }else if pickerView == countryPicker {
//            string = countryData[row].0
//        }
//        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white,
//            NSAttributedString.Key.font: UIFont(name: "Avenir-Bold", size: 20)])
//    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = view as? UILabel ?? UILabel()
        label.font = UIFont(name: "AmericanTypewriter-Semibold", size: 24)
        label.textColor = .white
        label.textAlignment = .center
        var string = ""
        if pickerView == durationPicker {
            string = durationData[row].0
        }else if pickerView == countryPicker {
            string = countryData[row].0
        }
        label.text = string
        return label
    }
    
    @IBAction func nextAction(_ sender: Any) {
    
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVc = segue.destination as! ViewController
        destinationVc.timeLimit = selectedDuration
        destinationVc.defaultLanguage = selectedCountryCode
    }
 

}
