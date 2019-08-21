//
//  ViewController.swift
//  Pitch Perfect
//
//  Created by juan on 8/20/19.
//  Copyright © 2019 jarcos. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func recordAudio(_ sender: UIButton) {
        recordingLabel.text = "Recording in Progress"
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        recordingLabel.text = "Stop Recording"
    }
}

