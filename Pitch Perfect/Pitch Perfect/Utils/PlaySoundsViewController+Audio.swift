//
//  PlaySoundsViewController+Audio.swift
//  PitchPerfect
//
//  Copyright Â© 2016 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - PlaySoundsViewController: AVAudioPlayerDelegate

extension PlaySoundsViewController: AVAudioPlayerDelegate {
    
    // MARK: Alerts
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    // MARK: PlayingState (raw values correspond to sender tags)
    
    enum PlayingState { case playing, notPlaying }
    
    // MARK: Audio Functions
    
    func setupAudio() {
        // initialize (recording) audio file
        guard let _recordedAudioURL = recordedAudioURL else {
            return
        }
        do {
            audioFile = try AVAudioFile(forReading: _recordedAudioURL as URL)
        } catch {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
    }
    
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        guard let _audioEngine = audioEngine, let _audioPlayerNode = audioPlayerNode else {
            return
        }
        _audioEngine.attach(_audioPlayerNode)
        
        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        _audioEngine.attach(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        _audioEngine.attach(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        _audioEngine.attach(reverbNode)
        
        // connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(_audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, _audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(_audioPlayerNode, changeRatePitchNode, echoNode, _audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(_audioPlayerNode, changeRatePitchNode, reverbNode, _audioEngine.outputNode)
        } else {
            connectAudioNodes(_audioPlayerNode, changeRatePitchNode, _audioEngine.outputNode)
        }
        
        
        guard let _audioFile = audioFile else {
            return
        }
        // schedule to play and start the engine!
        _audioPlayerNode.stop()
        _audioPlayerNode.scheduleFile(_audioFile, at: nil) {
            
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = _audioPlayerNode.lastRenderTime, let playerTime = _audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double(_audioFile.length - playerTime.sampleTime) / Double(_audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(_audioFile.length - playerTime.sampleTime) / Double(_audioFile.processingFormat.sampleRate)
                }
            }
            
            // schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoop.Mode.default)
        }
        
        do {
            try _audioEngine.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        // play the recording!
        _audioPlayerNode.play()
    }
    
    @objc func stopAudio() {
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        configureUI(.notPlaying)
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    // MARK: Connect List of Audio Nodes
    
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        guard let _audioEngine = audioEngine, let _audioFile = audioFile else {
            return
        }
        
        for x in 0..<nodes.count-1 {
            _audioEngine.connect(nodes[x], to: nodes[x+1], format: _audioFile.processingFormat)
            
        }
    }
    
    // MARK: UI Functions
    
    func configureUI(_ playState: PlayingState) {
        switch(playState) {
        case .playing:
            setPlayButtonsEnabled(false)
            stopButton.isEnabled = true
        case .notPlaying:
            setPlayButtonsEnabled(true)
            stopButton.isEnabled = false
        }
    }
    
    func setPlayButtonsEnabled(_ enabled: Bool) {
//        snailButton.isEnabled = enabled
//        chipmunkButton.isEnabled = enabled
//        rabbitButton.isEnabled = enabled
//        vaderButton.isEnabled = enabled
//        echoButton.isEnabled = enabled
//        reverbButton.isEnabled = enabled
        setEnableButton(contentView: self.view, enabled: enabled)
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
