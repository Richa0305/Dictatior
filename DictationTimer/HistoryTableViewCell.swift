//
//  HistoryTableViewCell.swift
//  DictationTimer
//
//  Created by Srivastava, Richa on 24/05/18.
//  Copyright © 2018 Srivastava, Richa. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var progressBarView: UIProgressView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var confidenceScoreLabel: UILabel!
    @IBOutlet weak var dictationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        progressBarView.transform = progressBarView.transform.scaledBy(x: 1, y: 3)
        dictationLabel.numberOfLines = 0
        dictationLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
