//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by juan on 8/21/19.
//  Copyright © 2019 jarcos. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var recordedAudioURL: URL?
    var audioFile: AVAudioFile?
    var audioEngine: AVAudioEngine?
    var audioPlayerNode: AVAudioPlayerNode?
    var stopTimer: Timer!
    
    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
        setContentModeImageButtonAndEnable(contentView: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureUI(.notPlaying)
    }
    
    @IBAction func playSoundForButton(_ sender: UIButton) {
        print("Play Sound Button Pressed")
        switch(ButtonType(rawValue: sender.tag)!) {
        case .slow:
            playSound(rate: 0.5)
        case .fast:
            playSound(rate: 1.5)
        case .chipmunk:
            playSound(pitch: 1000)
        case .vader:
            playSound(pitch: -1000)
        case .echo:
            playSound(echo: true)
        case .reverb:
            playSound(reverb: true)
        }
        
        configureUI(.playing)
    }
    
    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        print("Stop Audio Button Pressed")
        stopAudio()
    }
    
    
    func setContentModeImageButtonAndEnable( contentView: UIView, enable: Bool? = nil ) {
        for currentView in contentView.subviews {
            if let button = currentView as? UIButton {
                button.imageView?.contentMode = .scaleAspectFit
                if let enable = enable {
                    button.isEnabled = enable
                }
            }else if currentView.subviews.count > 0 {
                setContentModeImageButtonAndEnable(contentView: currentView, enable: enable)
            }
        }
    }
}
