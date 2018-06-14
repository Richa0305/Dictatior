//
//  ViewController.swift
//  DictationTimer
//
//  Created by Srivastava, Richa on 23/05/18.
//  Copyright © 2018 Srivastava, Richa. All rights reserved.
//

import UIKit
import Speech
import CoreData
import GoogleMobileAds

class ViewController: UIViewController, SFSpeechRecognizerDelegate, UIActionSheetDelegate, GADBannerViewDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var settingsOverUIView: UIView!
    @IBOutlet weak var confidenceScoreLabel: UILabel!
    @IBOutlet weak var confidenceProgressView: UIProgressView!
    @IBOutlet weak var timerOverView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    var countdownTimer = Timer()
    var speechRecognizer:SFSpeechRecognizer!
    var bannerView : GADBannerView!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var totalTime = 0
    var confidenceForText = Array<Float>()
    var currentConfidenceScore:Float = 0.0
    let appDelegare = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        confidenceProgressView.transform = confidenceProgressView.transform.scaledBy(x: 1, y: 5)
        // Do any additional setup after loading the view, typically from a nib.
        let defaultLanguage = "en-au";
        setupSpeechRecorder(language: defaultLanguage)
        
        // setup banner ad  
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.frame  = CGRect(x: 0, y: view.bounds.height - bannerView.frame.height, width: bannerView.frame.size.width, height: bannerView.frame.size.height)
        bannerView.delegate = self
        bannerView.rootViewController = self
        let request = GADRequest()
        //request.testDevices = [kGADSimulatorID]
        bannerView.adUnitID = "ca-app-pub-1382562788361552/1231860898"
        bannerView.load(request)
        self.view?.addSubview(bannerView)
       
    }
    
    func setupSpeechRecorder(language:String){
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: language))!
        microphoneButton.isEnabled = false
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
        print(SFSpeechRecognizer.supportedLocales())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        saveButton.isEnabled = false
        saveButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
        timerLabel.layer.masksToBounds = true
        timerLabel.layer.cornerRadius = 30
        
        timerOverView.layer.borderColor = UIColor.gray.cgColor
        timerOverView.layer.cornerRadius = 40
        timerOverView.layer.borderWidth = 2
        timerOverView.layer.masksToBounds = true
        
        settingsOverUIView.layer.cornerRadius = 30
        settingsOverUIView.layer.borderWidth = 2
        settingsOverUIView.layer.masksToBounds = true
        totalTime = 0
        timerLabel.text = "\(totalTime)"
        reset()
        
    }

    @IBAction func microphoneButtonAction(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            if audioEngine.isRunning {
                audioEngine.stop()
                confidenceForText.removeAll()
                recognitionRequest?.endAudio()
                microphoneButton.isEnabled = false
                microphoneButton.setTitle("Start Recording", for: .normal)
                reset()
                saveButton.isEnabled = true
                saveButton.setTitleColor(UIColor.white, for: UIControlState.normal)
                endTimer()
            } else {
                endTimer()
                reset()
                startTimer()
                startRecording()
                microphoneButton.setTitle("Stop Recording", for: .normal)
            }
        }
        
    }
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString
                
                isFinal = (result?.isFinal)!
                
                
                if isFinal  {
                    for item in (result?.transcriptions)!{
                        for seg in item.segments{
                            //print(seg.substring)
                            //print(seg.confidence)
                            self.confidenceForText.append(seg.confidence)
                        }
                        
                    }
                    //print("================")
                    var confidence:Float = 0.0
                    if self.confidenceForText.count > 0 {
                        for confidenceScore in self.confidenceForText{
                            print(confidence)
                            confidence += confidenceScore
                        }
                    }
                    confidence = confidence / Float(self.confidenceForText.count)
                    print("================")
                    print(confidence)
                    confidence = (round(confidence * 1000))/1000
                    self.confidenceScoreLabel.text = "Confidence Score : \(confidence * 100)%"
                    self.confidenceProgressView.progress = confidence
                    self.currentConfidenceScore = confidence
                }
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.endTimer()
                self.saveButton.isEnabled = true
                self.saveButton.setTitleColor(UIColor.white, for: UIControlState.normal)
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        textView.text = ""
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        totalTime += 1
        timerLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.2) {
            self.timerLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        timerLabel.text = "\(totalTime)"
    }
    
    func endTimer() {
        totalTime = 0
        countdownTimer.invalidate()
    }

    func startBlinkig(){
        microphoneButton.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.microphoneButton.alpha = 1
        }
    }
    func reset(){
        confidenceScoreLabel.text = "Confidence Score :"
        confidenceProgressView.progress = 0.0
        textView.text = ""
    }
    @IBAction func languageSettingsAction(_ sender: Any) {
        let optionMenuController = UIAlertController(title: nil, message: "Change language", preferredStyle: .actionSheet)
        
        // Create UIAlertAction for UIAlertController
        
        let us = UIAlertAction(title: "English (US)", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.setupSpeechRecorder(language: "en-US")
        })
        let uk = UIAlertAction(title: "English (UK)", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
           
            self.setupSpeechRecorder(language: "en-GB")
        })
        
        let australian = UIAlertAction(title: "English (Australian)", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.setupSpeechRecorder(language: "en-AU")
        })
        let ireland = UIAlertAction(title: "English (Canadian)", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.setupSpeechRecorder(language: "en-CA")
        })
        let spanish = UIAlertAction(title: "Spanish", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.setupSpeechRecorder(language: "es-ES")
        })
        let spanishMaxican = UIAlertAction(title: "Spanish (Maxican)", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.setupSpeechRecorder(language: "es-MX")
        })
       
        let spanishColombian = UIAlertAction(title: "Spanish (Colombian)", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.setupSpeechRecorder(language: "es-CO")
        })
        let french = UIAlertAction(title: "French", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.setupSpeechRecorder(language: "fr-FR")
        })
    
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        // Add UIAlertAction in UIAlertController
        
        optionMenuController.addAction(us)
        optionMenuController.addAction(uk)
        optionMenuController.addAction(australian)
        optionMenuController.addAction(ireland)
        optionMenuController.addAction(spanish)
        optionMenuController.addAction(spanishMaxican)
        optionMenuController.addAction(spanishColombian)
        optionMenuController.addAction(french)
        optionMenuController.addAction(cancel)
        
        
        optionMenuController.popoverPresentationController?.sourceView = sender as! UIView
        
        // Present UIAlertController with Action Sheet
        
        self.present(optionMenuController, animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        if textView.text.count > 1 {
            let context = appDelegare.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "History", in: context)
            let newentry = NSManagedObject(entity: entity!, insertInto: context)
                        newentry.setValue(textView.text, forKey: "dictation")
                        newentry.setValue(timerLabel.text, forKey: "duration")
                        newentry.setValue(currentConfidenceScore, forKey: "confidencescore")
            
            do{
                try context.save()
            }catch{
                
            }
        }
        
    }
    
    
    
    func save() {
        // Just to get screenshots call this function
        //if textView.text.count > 1 {
            let context = appDelegare.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "History", in: context)
            let newentry = NSManagedObject(entity: entity!, insertInto: context)
            //            newentry.setValue(textView.text, forKey: "dictation")
            //            newentry.setValue(timerLabel.text, forKey: "duration")
            //            newentry.setValue(currentConfidenceScore, forKey: "confidencescore")
            
            newentry.setValue("Technology can be deemed to be pretty good at regulating external reality to foster real biological fitness, however, it's an undeniable fact that it’s even better at rendering fake fitness — subjective indication of reproduction and survival without the real-world effects. Fitness-faking technology has a proclivity to evolve at a much faster pace even more than our psychological resistance.", forKey: "dictation")
            newentry.setValue("38", forKey: "duration")
            newentry.setValue(0.875, forKey: "confidencescore")
            do{
                try context.save()
            }catch{
                
            }
       // }
        
    }
    
}

