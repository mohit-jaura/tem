//
//  AVCaptureSession+Extensions.swift
//  YPImagePicker
//
//  Created by Nik Kov on 23.04.2018.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import AVFoundation

extension AVCaptureSession {
    func resetInputs() {
        // remove all sesison inputs
        for i in inputs {
            removeInput(i)
        }
    }
}
