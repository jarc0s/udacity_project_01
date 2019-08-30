//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by juan on 8/20/19.
//  Copyright © 2019 jarcos. All rights reserved.
//

import UIKit
import AVFoundation


class RecordSoundsViewController: UIViewController {
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabelRecordStatus(isRecord: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            if let playSoundViewController = segue.destination as? PlaySoundsViewController, let recordedAudioUrl = sender as? URL  {
                playSoundViewController.recordedAudioURL = recordedAudioUrl
            }
            
        }
    }

    @IBAction func recordAudio(_ sender: UIButton) {
        
        updateLabelRecordStatus(isRecord: true)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = Constants.AudioFile.fileName
        let pathArray = [dirPath, recordingName]
        let stringPath = pathArray.joined(separator: "/")
        let filePath = URL(string: stringPath)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        updateLabelRecordStatus(isRecord: false)
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    /**
     Update the UI labels and buttons is the current state is recording an audio
     - Author:
     JArcos
     - returns:
     NO return for this function
     - throws:
     No Exception
     - parameters:
        - isRecord: Bool who indicate if the current state is recording
     - Important:
     The current tag string is set by default
     - Version:
     0.1
     
     */
    func updateLabelRecordStatus(isRecord: Bool){
        recordingLabel.text = isRecord ? Constants.LabelsRecordScreen.recording: Constants.LabelsRecordScreen.notRecording
        stopRecordingButton.isEnabled = isRecord
        recordButton.isEnabled = !isRecord
    }
    
}

extension RecordSoundsViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        }else {
            print("recording was not successfully" )
        }
    }
}
