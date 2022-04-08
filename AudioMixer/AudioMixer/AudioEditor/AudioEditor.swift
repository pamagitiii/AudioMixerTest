//
//  AudioEditor.swift
//  AudioMixer
//
//  Created by Anatoliy on 06.04.2022.
//

import AVFoundation

//class AudioEditor {
//    func mergeAudioFiles(audioFileUrls: [URL]) -> AVPlayerItem? {
//            let composition = AVMutableComposition()
//
//            for i in 0 ..< audioFileUrls.count {
//                let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
//                //let filePath = "\(Utilities.getDocumentsDirectory())"+Utilities.getFileName(audioFileUrls[i].path)
//
//                let asset = AVURLAsset(url: audioFileUrls[i])
//
//                let trackContainer = asset.tracks(withMediaType: AVMediaType.audio)
//
//                guard trackContainer.count > 0 else{
//                    return nil
//                }
//
//                let audioTrack = trackContainer[0]
//                let timeRange = CMTimeRange(start: CMTimeMake(value: 0, timescale: 600), duration: audioTrack.timeRange.duration)
//                try! compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: composition.duration)
//            }
//
//
//        let assertExport = AVAssetExportSession(asset: composition, presetName: "song")
//        assertExport?.outputFileType = .mp3
//
//
//
//            return AVPlayerItem(asset: composition)
//    }
//
//    /**
//    Get the set document directory for the application
//    */
//    func getDocumentsDirectory() -> URL {
//            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//            let documentsDirectory = paths[0]
//            return documentsDirectory
//    }
//
//    /**
//    get filename from a given file url or path
//    - parameter fileUrl: file path to be extracted
//    - returns: filename : String
//    */
//    func getFileName(_ fileUrl : String) -> String{
//            return URL(string: fileUrl)!.lastPathComponent
//    }
//
//}





//пример с гитхаба
/*

func mergeVideoAndMusicWithVolume(videoURL: NSURL, audioURL: NSURL, startAudioTime: Float64, volumeVideo: Float, volumeAudio: Float, complete: ((NSURL?)) -> Void) -> Void {

   //The goal is merging a video and a music from iPod library, and set it a volume

   //Get the path of App Document Directory
   let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
   let docsDir = dirPaths[0] as String

   //Create Asset from record and music
   let assetVideo: AVURLAsset = AVURLAsset(URL: videoURL)
   let assetMusic: AVURLAsset = AVURLAsset(URL: audioURL)

   let composition: AVMutableComposition = AVMutableComposition()
   let compositionVideo : AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
   let compositionAudioVideo: AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
   let compositionAudioMusic: AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())

   //Add video to the final record

   do {
       try compositionVideo.insertTimeRange(CMTimeRangeMake(kCMTimeZero, assetVideo.duration), ofTrack:assetVideo.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: kCMTimeZero)
   } catch _ {
   }

   //Extract audio from the video and the music
   let audioMix: AVMutableAudioMix = AVMutableAudioMix()
   var audioMixParam: [AVMutableAudioMixInputParameters] = []

   let assetVideoTrack: AVAssetTrack = assetVideo.tracksWithMediaType(AVMediaTypeAudio)[0]
   let assetMusicTrack: AVAssetTrack = assetMusic.tracksWithMediaType(AVMediaTypeAudio)[0]

   let videoParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: assetVideoTrack)
   videoParam.trackID = compositionAudioVideo.trackID

   let musicParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: assetMusicTrack)
   musicParam.trackID = compositionAudioMusic.trackID

   //Set final volume of the audio record and the music
   videoParam.setVolume(volumeVideo, atTime: kCMTimeZero)
   musicParam.setVolume(volumeAudio, atTime: kCMTimeZero)

   //Add setting
   audioMixParam.append(musicParam)
   audioMixParam.append(videoParam)

   //Add audio on final record
   //First: the audio of the record and Second: the music
   do {
   try compositionAudioVideo.insertTimeRange(CMTimeRangeMake(kCMTimeZero, assetVideo.duration), ofTrack: assetVideoTrack, atTime: kCMTimeZero)
   } catch _ {
   assertionFailure()
   }

   do {
   try compositionAudioMusic.insertTimeRange(CMTimeRangeMake(CMTimeMake(Int64(startAudioTime * 10000), 10000), assetVideo.duration), ofTrack: assetMusicTrack, atTime: kCMTimeZero)
   } catch _ {
   assertionFailure()
   }

   //Add parameter
   audioMix.inputParameters = audioMixParam

   //Remove the previous temp video if exist
   let filemgr = NSFileManager.defaultManager()
       do {
           if filemgr.fileExistsAtPath("\(docsDir)"){
               try filemgr.removeItemAtPath("\(docsDir)/movie-merge-music.mp4")
           } else {
           }
           } catch _ {
       }
   //Exporte the final record’
   let completeMovie = "\(docsDir)/\(randomString(5)).mp4"
   let completeMovieUrl = NSURL(fileURLWithPath: completeMovie)
   let exporter: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!

   exporter.outputURL = completeMovieUrl
   exporter.outputFileType = AVFileTypeMPEG4
   exporter.audioMix = audioMix
   exporter.exportAsynchronouslyWithCompletionHandler({

   switch exporter.status {

   case AVAssetExportSessionStatus.Completed:
       print("success with output url \(completeMovieUrl)")
       case  AVAssetExportSessionStatus.Failed:
           print("failed \(String(exporter.error))")
       case AVAssetExportSessionStatus.Cancelled:
           print("cancelled \(String(exporter.error))")
       default:
           print("complete")
       }
   })
}
*/
