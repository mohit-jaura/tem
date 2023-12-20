//
//  UIImage+Extension.swift
//  TemApp
//
//  Created by shilpa on 08/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Kingfisher
extension UIImage {
    
    func resizeImage(image: UIImage, newHeight: CGFloat) -> UIImage? {
        
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    public func fixedOrientation() -> UIImage {
        
        if imageOrientation == UIImage.Orientation.up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
        case UIImage.Orientation.up, UIImage.Orientation.upMirrored:
            break
        }
        
        switch imageOrientation {
        case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.up, UIImage.Orientation.down, UIImage.Orientation.left, UIImage.Orientation.right:
            break
        }
        
        let ctx: CGContext = CGContext(data: nil,
                                       width: Int(size.width),
                                       height: Int(size.height),
                                       bitsPerComponent: self.cgImage!.bitsPerComponent,
                                       bytesPerRow: 0,
                                       space: self.cgImage!.colorSpace!,
                                       bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        let cgImage: CGImage = ctx.makeImage()!
        
        return UIImage(cgImage: cgImage)
    }
    
    func getImageRatio() -> CGFloat {
        let imageRatio = CGFloat(self.size.width / self.size.height)
        return imageRatio
    }
}

extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage? {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0) 
        self.draw(in: CGRect(x:0, y:0, width: newSize.width, height: newSize.height))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage? {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }
    
}

extension UIImageView {
    func frameForPhoto() -> CGRect {
        if self.image == nil {
            return CGRect.zero
        }
        //let zoomScale = 1.0
        var photoDisplayedFrame: CGRect
        if self.contentMode == .scaleAspectFit {
            photoDisplayedFrame = AVMakeRect(aspectRatio: self.image?.size ?? CGSize.zero, insideRect: self.frame)
        } else {
            photoDisplayedFrame = self.frame
        }
        return photoDisplayedFrame
    }
    func setImg(_ urlStr:String?,_ placeholderImg:UIImage? = UIImage.placeHolder) {
        if let urlStr = urlStr,let url = URL(string: urlStr) {
            self.kf.setImage(with: url, placeholder: placeholderImg)
        }else {
            self.image = placeholderImg
        }
    }
    func setImgwithUrl(_ url:URL?,_ placeholderImg:UIImage? = UIImage(named: "no-image")) {
        if let url = url{
            self.kf.setImage(with: url, placeholder: UIImage(named: "no-image"))
        }else {
            self.image = placeholderImg
        }
    }
    
    //It will add the shadow as well as honeycomb shape on an imageview
    func addShadowToHoneycombView(colorsetValue:UIColor = #colorLiteral(red: 0.2445561886, green: 0.5110852718, blue: 0.8627218604, alpha: 1)){
        let path = UIBezierPath(rect: self.bounds, sides: 6, lineWidth: 5, cornerRadius: 0)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillColor       = colorsetValue.cgColor
        mask.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mask.shadowOffset = CGSize(width: 2, height: 2)//CGSize(width: 0.0, height: 2.8)
        mask.shadowOpacity = 0.6
      self.layer.insertSublayer(mask, at: 0)
        
        let mask2 = CAShapeLayer()
        mask2.path = path.cgPath
        mask2.fillColor       = colorsetValue.cgColor
        mask2.shadowColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mask2.shadowOffset = CGSize(width: -1, height: -1)//CGSize(width: 0.0, height: 2.8)
        mask2.shadowOpacity = 0.6
     self.layer.insertSublayer(mask2, at: 0)
    }
}

class ScaledHeightImageView: UIImageView {
    override var intrinsicContentSize: CGSize {
        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width

            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio

            return CGSize(width: myViewWidth, height: scaledHeight)
        }
        return CGSize(width: -1.0, height: -1.0)
    }

}
class ImageSaver: NSObject {
    var imgID = 0
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
