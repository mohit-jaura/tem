//
//  URL+Extension.swift
//
//  Created by Dhiraj on 17/06/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
extension URL {

    
    /// converts video URL to UIImage
    ///
    /// - Parameter url: Video URL
    /// - Returns: thumbnail for video
    func getVideoThumbnailAndDuaration(url : URL) -> UIImage?{
        let asset: AVAsset = AVAsset(url: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time        : CMTime = CMTimeMake(value: 1, timescale: 30)
        let img         : CGImage
        do {
            try img = assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let frameImg: UIImage = UIImage(cgImage: img)
            return frameImg
        } catch {
            
        }
        return nil
    }
    
    /// convert CMTime to seconds
    ///
    /// - Parameter time: pass CMTime for a video
    /// - Returns: retun duration in minutes & seconds
    func getDuration() -> Double {
        
        let asset: AVAsset = AVAsset(url: self)
        let time = asset.duration.seconds//asset.duration.seconds.toInt()
        /*if let time = time {
            DILog.print(items:"Duration is \(time)")
            let minutes = String(time / 60)
            let seconds = time % 60
            let secondsDisplayString = seconds >= 10 ? "\(seconds)" : "0\(seconds)"
            return minutes + ":" + secondsDisplayString
        } else {
            return ""
        } */
        return time
    }
    
    func valueOf(_ queryParamaterName: String) -> String? {
        
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
        
    }

}


