//
//  ViewController.swift
//  AudioMixer
//
//  Created by Anatoliy on 06.04.2022.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: - Properties
    private let songs = ["Baker Street", "Feel", "Si", "Beast"]
    private var isPlaying = false {
        didSet {
            if isPlaying == true {
                playButton.setBackgroundImage(UIImage(systemName: "stop.circle")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), for: .normal)
                
                crossfadeSlider.isUserInteractionEnabled = false
                firstSongButton.isUserInteractionEnabled = false
                secondSongButton.isUserInteractionEnabled = false
                
            } else {
                playButton.setBackgroundImage(UIImage(systemName: "play.circle")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal), for: .normal)
                
                crossfadeSlider.isUserInteractionEnabled = true
                firstSongButton.isUserInteractionEnabled = true
                secondSongButton.isUserInteractionEnabled = true
            }
        }
    }
    
    //URLы выбранных пользователем песен
    private var firstSongURL: URL?
    private var secondSongURL: URL?
    
    //эту песню  будем ставить первой
    private var finalSongURL: URL?
    
    //эту песню будем ставить на репит
    private var loopingSongURL: URL?
    
    private var crossfadeValue: Float = 5
    private let step: Float = 1
    
    private var audioPlayer = AVAudioPlayer()
    private let filemgr = FileManager.default
    
    // MARK: - UI Properties
    private let playButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "play.circle")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        return button
    }()
    
    private let crossfadeValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemGray
        label.text = "Crossfade timing is 5 sec."
        return label
    }()
    
    private let crossfadeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 2
        slider.maximumValue = 10
        slider.setValue(5, animated: false)
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        return slider
    }()
    
    private let firstSongButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemGray
        button.setTitle("Choose first song", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(presentFirstSongAlert), for: .touchUpInside)
        return button
    }()
    
    private let secondSongButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemGray
        button.setTitle("Choose second song", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(presentSecondSongAlert), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    // MARK: - Methods
    private func setupUI() {
        view.addSubviews([crossfadeSlider, crossfadeValueLabel, firstSongButton, secondSongButton, playButton])
        
        NSLayoutConstraint.activate([crossfadeSlider.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70),
                                     crossfadeSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     crossfadeSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                                     crossfadeSlider.heightAnchor.constraint(equalToConstant: 20)])
        
        NSLayoutConstraint.activate([crossfadeValueLabel.bottomAnchor.constraint(equalTo: crossfadeSlider.topAnchor, constant: -10),
                                     crossfadeValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     crossfadeValueLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                                     crossfadeValueLabel.heightAnchor.constraint(equalToConstant: 20)])
        
        NSLayoutConstraint.activate([firstSongButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
                                     firstSongButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     firstSongButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
                                     firstSongButton.heightAnchor.constraint(equalToConstant: 50)])
        
        NSLayoutConstraint.activate([secondSongButton.topAnchor.constraint(equalTo: firstSongButton.bottomAnchor, constant: 50),
                                     secondSongButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     secondSongButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
                                     secondSongButton.heightAnchor.constraint(equalToConstant: 50)])
        
        NSLayoutConstraint.activate([playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                     playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     playButton.widthAnchor.constraint(equalToConstant: 50),
                                     playButton.heightAnchor.constraint(equalToConstant: 50)])
    }
    
    @objc private func playTapped() {
        switch isPlaying {
        case true:
            audioPlayer.stop()
            if finalSongURL != nil && loopingSongURL != nil {
                if filemgr.fileExists(atPath: finalSongURL!.path) && filemgr.fileExists(atPath: loopingSongURL!.path) {
                    do {
                        try filemgr.removeItem(at: finalSongURL!) //мы проверили что файл существует и удаляем его
                        try filemgr.removeItem(at: loopingSongURL!) //мы проверили что файл существует и удаляем его
                    } catch let error {
                        presentAlert(withTitle: "Can't delete audio", message: error.localizedDescription)
                    }
                }
            }
            
            isPlaying = false
            
        case false:
            guard let firstSongURL = firstSongURL, let secondSongURL = secondSongURL else {
                presentAlert(withTitle: "Select two songs", message: "with the buttons above")
                return
            }
            
            playButton.isUserInteractionEnabled = false
            mergeAudioFiles(firstSongURL: firstSongURL, secondSongURL: secondSongURL, crossfadeValue: crossfadeValue)
        }
    }
    
    @objc private func sliderValueDidChange(_ sender: UISlider) {
        let roundedStepValue = round(sender.value / step) * step
        sender.value = roundedStepValue
        crossfadeValue = Float(roundedStepValue)
        crossfadeValueLabel.text = "Crossfade timing is \(Int(roundedStepValue)) sec."
    }
}

// MARK: - Alerts for songs selecting
private extension ViewController {
    @objc private func presentFirstSongAlert() {
        let alertController = UIAlertController(title: "Choose first song", message: nil, preferredStyle: .actionSheet)
        
        for song in songs {
            let action = UIAlertAction(title: song, style: .default) { _ in
                let audioPath = Bundle.main.path(forResource: song, ofType: "mp3")!
                self.firstSongURL = URL(fileURLWithPath: audioPath)
                
                self.firstSongButton.backgroundColor = .systemGreen
                self.firstSongButton.setTitle(song, for: .normal)
            }
            alertController.addAction(action)
        }
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func presentSecondSongAlert() {
        let alertController = UIAlertController(title: "Choose second song", message: nil, preferredStyle: .actionSheet)
        
        for song in songs {
            let action = UIAlertAction(title: song, style: .default) { _ in
                let audioPath = Bundle.main.path(forResource: song, ofType: "mp3")!
                self.secondSongURL = URL(fileURLWithPath: audioPath)
                
                self.secondSongButton.backgroundColor = .systemGreen
                self.secondSongButton.setTitle(song, for: .normal)
            }
            alertController.addAction(action)
        }
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Merging and saving audios
private extension ViewController {
    func mergeAudioFiles(firstSongURL: URL, secondSongURL: URL, crossfadeValue: Float) {
        
        let crossfadeTiming = crossfadeValue / 2
        
        //финальная композиция
        let composition = AVMutableComposition()
        
        //ассеты по URL
        let assertFirstAudio = AVURLAsset(url: firstSongURL)
        let assertSecondAudio = AVURLAsset(url: secondSongURL)
        
        if assertFirstAudio.duration.seconds < Double(crossfadeValue) || assertSecondAudio.duration.seconds < Double(crossfadeValue) {
            presentAlert(withTitle: "Can't apply crossfade effect", message: "one of songs is shorter than effect")
            playButton.isUserInteractionEnabled = true
            return
        }
        
        //добавляем два трека на композицию
        let compositionFirstAudio: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
        let compositionSecondAudio: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
        
        //создаём аудиомикс
        let audioMix = AVMutableAudioMix()
        var audioMixParam: [AVMutableAudioMixInputParameters] = []
        
        //ассеты для каждого трека
        let firstTrack = assertFirstAudio.tracks(withMediaType: AVMediaType.audio).first!
        let secondTrack = assertSecondAudio.tracks(withMediaType: AVMediaType.audio).first!
        
        //параметры для первого
        let firstTrackParam = AVMutableAudioMixInputParameters(track: firstTrack)
        firstTrackParam.trackID = compositionFirstAudio.trackID
        
        //параметры для второго
        let secondTrackParam = AVMutableAudioMixInputParameters(track: secondTrack)
        secondTrackParam.trackID = compositionSecondAudio.trackID
        
        firstTrackParam.setVolumeRamp(fromStartVolume: 1,
                                      toEndVolume: 0,
                                      timeRange: CMTimeRange(start: assertFirstAudio.duration - CMTime(seconds: Double(crossfadeTiming), preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                                             end: firstTrack.timeRange.end))
        
        firstTrackParam.setVolumeRamp(fromStartVolume: 0,
                                      toEndVolume: 1,
                                      timeRange: CMTimeRange(start: firstTrack.timeRange.end,
                                                             end: firstTrack.timeRange.duration + CMTime(seconds: Double(crossfadeTiming), preferredTimescale: CMTimeScale(NSEC_PER_SEC))))
        
        firstTrackParam.setVolumeRamp(fromStartVolume: 1,
                                      toEndVolume: 0,
                                      timeRange: CMTimeRange(start: assertFirstAudio.duration + assertSecondAudio.duration - CMTime(seconds: Double(crossfadeTiming), preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                                             end: assertFirstAudio.duration + assertSecondAudio.duration))
        
        
        audioMixParam.append(firstTrackParam)
        audioMixParam.append(secondTrackParam)
        
        //добавляем первый трек
        let firstTrackTimeRange = CMTimeRange(start: CMTime.zero, duration: assertFirstAudio.duration)
        try! compositionFirstAudio.insertTimeRange(firstTrackTimeRange, of: firstTrack, at: CMTime.zero)
        
        //добавляем ввторой трек
        let secondTrackTimeRange = CMTimeRange(start: CMTime.zero, duration: assertSecondAudio.duration)
        try! compositionFirstAudio.insertTimeRange(secondTrackTimeRange, of: secondTrack, at: assertFirstAudio.duration)
        
        //добавляем параметры микса
        audioMix.inputParameters = audioMixParam
        //print(audioMix.inputParameters)
        
        //путь для сохранения конечного трека
        let finalUrl = URL(string: "\(getDocumentsDirectory())\(UUID().uuidString)_audio.m4a")
        guard let finalUrl = finalUrl else {
            presentAlert(withTitle: "Can't save audio", message: "")
            playButton.isUserInteractionEnabled = true
            return
        }
        
        //сохраняем
        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        assetExport?.outputFileType = AVFileType.m4a
        assetExport?.audioMix = audioMix
        assetExport?.outputURL = finalUrl
        
        finalSongURL = finalUrl
        
        assetExport?.exportAsynchronously(completionHandler: {
            print(finalUrl.path)
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: finalUrl)
                self.audioPlayer.delegate = self
                self.audioPlayer.volume = 1
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.play()
                
                DispatchQueue.main.async {
                    self.playButton.isUserInteractionEnabled = true
                    self.isPlaying = true
                }
                
            } catch let error {
                self.presentAlert(withTitle: "Error with playing audio", message: error.localizedDescription)
            }
        })
        
        // MARK: - Здесь "сводим" второй трек, который будем ставить на репит
        //тайминги как и в первой композиции
        
        //создаём вторую композицию
        let loopComposition = AVMutableComposition()
        
        //добавляем два трека на композицию
        let loopCompositionFirstAudio: AVMutableCompositionTrack = loopComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
        let loopCompositionSecondAudio: AVMutableCompositionTrack = loopComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
        
        //создаём аудиомикс
        let loopAudioMix = AVMutableAudioMix()
        var loopAudioMixParam: [AVMutableAudioMixInputParameters] = []
        
        //ассеты для каждого трека
        let loopFirstTrack = assertFirstAudio.tracks(withMediaType: AVMediaType.audio).first!
        let loopSecondTrack = assertSecondAudio.tracks(withMediaType: AVMediaType.audio).first!
        
        //параметры для первого
        let loopFirstTrackParam = AVMutableAudioMixInputParameters(track: loopFirstTrack)
        loopFirstTrackParam.trackID = loopCompositionFirstAudio.trackID
        
        //параметры для второго
        let loopSecondTrackParam = AVMutableAudioMixInputParameters(track: loopSecondTrack)
        loopSecondTrackParam.trackID = loopCompositionSecondAudio.trackID
        
        loopFirstTrackParam.setVolumeRamp(fromStartVolume: 0,
                                          toEndVolume: 1,
                                          timeRange: CMTimeRange(start: CMTime.zero,
                                                                 end: CMTime(seconds: Double(crossfadeTiming), preferredTimescale: CMTimeScale(NSEC_PER_SEC))))
        
        loopFirstTrackParam.setVolumeRamp(fromStartVolume: 1,
                                      toEndVolume: 0,
                                      timeRange: CMTimeRange(start: assertFirstAudio.duration - CMTime(seconds: Double(crossfadeTiming), preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                                             end: firstTrack.timeRange.end))
        
        loopFirstTrackParam.setVolumeRamp(fromStartVolume: 0,
                                      toEndVolume: 1,
                                      timeRange: CMTimeRange(start: firstTrack.timeRange.end,
                                                             end: firstTrack.timeRange.duration + CMTime(seconds: Double(crossfadeTiming), preferredTimescale: CMTimeScale(NSEC_PER_SEC))))
        
        loopFirstTrackParam.setVolumeRamp(fromStartVolume: 1,
                                      toEndVolume: 0,
                                      timeRange: CMTimeRange(start: assertFirstAudio.duration + assertSecondAudio.duration - CMTime(seconds: Double(crossfadeTiming), preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                                             end: assertFirstAudio.duration + assertSecondAudio.duration))
        
        loopAudioMixParam.append(loopFirstTrackParam)
        loopAudioMixParam.append(loopSecondTrackParam)
        
        //добавляем первый трек
        let loopFirstTrackTimeRange = CMTimeRange(start: CMTime.zero, duration: assertFirstAudio.duration)
        try! loopCompositionFirstAudio.insertTimeRange(loopFirstTrackTimeRange, of: loopFirstTrack, at: CMTime.zero)
        
        //добавляем ввторой трек
        let loopSecondTrackTimeRange = CMTimeRange(start: CMTime.zero, duration: assertSecondAudio.duration)
        try! loopCompositionSecondAudio.insertTimeRange(loopSecondTrackTimeRange, of: loopSecondTrack, at: assertFirstAudio.duration)
        
        //добавляем параметры микса
        loopAudioMix.inputParameters = loopAudioMixParam
        print(loopAudioMix.inputParameters)
        
        //путь для сохранения второго трека
        let loopFinalUrl = URL(string: "\(getDocumentsDirectory())\(UUID().uuidString)_loopAudio.m4a")
        guard let loopFinalUrl = loopFinalUrl else {
            presentAlert(withTitle: "Can't save audio", message: "")
            return
        }
        
        //сохраняем
        let secondAssetExport = AVAssetExportSession(asset: loopComposition, presetName: AVAssetExportPresetAppleM4A)
        secondAssetExport?.outputFileType = AVFileType.m4a
        secondAssetExport?.audioMix = loopAudioMix
        secondAssetExport?.outputURL = loopFinalUrl
        
        loopingSongURL = loopFinalUrl
        
        secondAssetExport?.exportAsynchronously(completionHandler: {
            self.loopingSongURL = loopFinalUrl
        })
        
    }
    
    // MARK: - Helper function
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}
// MARK: - Audio Player Delegate
extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if loopingSongURL != nil {
            do {
                print("looping song is playing!")
                audioPlayer = try AVAudioPlayer(contentsOf: loopingSongURL!)
                audioPlayer.delegate = self
                audioPlayer.volume = 1
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch let error {
                self.presentAlert(withTitle: "Error with playing audio", message: error.localizedDescription)
                playTapped()
            }
        }
    }
}
