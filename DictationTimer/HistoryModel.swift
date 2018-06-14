//
//  HistoryModel.swift
//  DictationTimer
//
//  Created by Srivastava, Richa on 24/05/18.
//  Copyright © 2018 Srivastava, Richa. All rights reserved.
//

import Foundation

class HistoryModel{
    
    var dictation:String = ""
    var duration:String = ""
    var confidenceScore:Float = 0.0
    
    init() {
        self.dictation = ""
        self.duration = ""
        self.confidenceScore = 0.0
    }
}
