//
//  CoreScanner.swift
//  Hackthon
//
//  Created by Himanshu Saraswat on 08/06/23.
//

import Foundation
import Photos
import UIKit

public enum DocumentState {
    case capture
    case loading
    case success
    case failure
}

public enum FlashPhotoMode {
    case on
    case off
}

open class CoreScanner: UIViewController {
    // MARK: Properties
    var flashPhotoMode: FlashPhotoMode = .off
    var captureDevice: AVCaptureDevice!
    public var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    public var captureSession: AVCaptureSession?
    
    // MARK: Method for focus
//    func addFocusArea(cornerColor: UIColor) {
//        let lineSize = CGFloat(34)
//        let cornerRadius = CGFloat(10.91)
//        let width = UIScreen.main.bounds.width * 0.733
//        let height = (UIScreen.main.bounds.height * 0.56)
//        let yValue = UIScreen.main.bounds.height * 0.255
//        let xValue = (UIScreen.main.bounds.width - width)  / 2
//        let viewSize = CGRect(x: xValue, y: yValue, width: width, height: height)
//        let path = UIBezierPath()
//
//        //top right
//        path.move(to:  CGPoint(x: viewSize.width - lineSize, y: 0))
//        path.addLine(to: CGPoint(x: viewSize.width - lineSize, y: 0))
//        path.addArc(
//            withCenter: CGPoint(
//                x: viewSize.width - cornerRadius,
//                y: cornerRadius
//            ),
//            radius: cornerRadius,
//            startAngle: CGFloat(Double.pi * 3 / 2),
//            endAngle: CGFloat(0),
//            clockwise: true
//        )
//        path.addLine(to: CGPoint(x: viewSize.width, y: lineSize))
//
//        //bottom right
//        path.move(to:  CGPoint(x: viewSize.width , y: viewSize.height-lineSize))
//        path.addLine(to: CGPoint(x: viewSize.width , y: viewSize.height-lineSize))
//        path.addArc(
//            withCenter: CGPoint(
//                x: viewSize.width - cornerRadius,
//                y: viewSize.height - cornerRadius
//            ),
//            radius: cornerRadius,
//            startAngle: CGFloat(0),
//            endAngle: CGFloat(Double.pi / 2),
//            clockwise: true
//        )
//        path.addLine(to: CGPoint(x: viewSize.width - lineSize, y: viewSize.height))
//
//        //top left
//        path.move(to: CGPoint(x: 0, y: lineSize))
//        path.addLine(to: CGPoint(x: 0, y: lineSize))
//        path.addArc(
//            withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
//            radius: cornerRadius,
//            startAngle: CGFloat(Double.pi),
//            endAngle: CGFloat(Double.pi / 2 * 3),
//            clockwise: true
//        )
//        path.addLine(to: CGPoint(x: lineSize, y: 0))
//
//        //bottom left
//        path.move(to: CGPoint(x: lineSize, y: viewSize.height))
//
//        path.addLine(to: CGPoint(x: lineSize, y: viewSize.height))
//
//        path.addArc(
//            withCenter: CGPoint(
//                x: cornerRadius,
//                y: viewSize.height - cornerRadius
//            ),
//            radius: cornerRadius,
//            startAngle: CGFloat(Double.pi / 2),
//            endAngle: CGFloat(Double.pi),
//            clockwise: true
//        )
//        path.addLine(to: CGPoint(x: 0, y: viewSize.height - lineSize))
//
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.frame = viewSize
//        shapeLayer.path = path.cgPath
//        shapeLayer.strokeColor = cornerColor.cgColor
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.lineWidth = 4
//        shapeLayer.lineCap = .round
//        self.view.layer.addSublayer(shapeLayer)
//        self.view.clipsToBounds = true
//    }
    
    // MARK: Camera methods
    /// Enable/Disable flash
    @objc public func toggleFlashPhotoMode() {
        var isFlashPhotoModeOn = flashPhotoMode == .on
        isFlashPhotoModeOn.toggle()
        flashPhotoMode = isFlashPhotoModeOn ? .on : .off
        self.setUpFlashMode()
    }
    /// Setup flash functionality
    /// can be turn OFF/ON
    func setUpFlashMode() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        do {
            if captureDevice != nil {
                if captureDevice.hasTorch {
                    try captureDevice.lockForConfiguration()
                    captureDevice.torchMode = self.flashPhotoMode == .on ? .on : .off
                    captureDevice?.unlockForConfiguration()
                }
            }
        } catch {
            //error
        }
    }
    /// Close camera
    func closeCamera() {
        if let captureSession = captureSession,
           captureSession.isRunning {
            captureSession.stopRunning()
        }
        captureSession = nil
        videoPreviewLayer?.removeFromSuperlayer()
        videoPreviewLayer = nil
        do {
            if captureDevice !=  nil {
                if captureDevice.hasTorch {
                    try captureDevice.lockForConfiguration()
                    captureDevice?.torchMode = .off
                    captureDevice?.unlockForConfiguration()
                }
            }
        } catch {
            // error
        }
    }
}


