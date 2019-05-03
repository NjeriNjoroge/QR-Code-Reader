//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerController: UIViewController {

    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
  
  var captureSession = AVCaptureSession()
  var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  var qrCodeFrameView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

      //get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
      
      guard let captureDevice = deviceDiscoverySession.devices.first else {
        print("Failed to get the camera device")
        return
      }
      
      do {
        //Get an instance of the AVCaptureDeviceInput class using the previous device object
        let input = try AVCaptureDeviceInput(device: captureDevice)
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        //Set the input device on the capture session
        captureSession.addInput(input)
        
        //Set the delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        //initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        //Start video capture
        captureSession.startRunning()
        
        //Initialize QR code frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
          qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
          qrCodeFrameView.layer.borderWidth = 2
          view.addSubview(qrCodeFrameView)
          view.bringSubview(toFront: qrCodeFrameView)
        }

      } catch {
        //if any errors, print them out
        print(error)
        return
      }
      
      //Move the message label and top bar to the front
      view.bringSubview(toFront: messageLabel)
      view.bringSubview(toFront: topbar)
    }
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
  //Capturing the QR code anf decoding the information
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    
    //Check if the metadataObjects array is not nil and it contains atleast one object.
    if metadataObjects.count == 0 {
      qrCodeFrameView?.frame = CGRect.zero
      messageLabel.text = "No QR code is detected"
      return
    }
    
    //Get the metadata object
    let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
    
    if metadataObj.type == AVMetadataObject.ObjectType.qr {
      //If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
      let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
      qrCodeFrameView?.frame = barCodeObject!.bounds
      
      if metadataObj.stringValue != nil {
        messageLabel.text = metadataObj.stringValue
      }
    }
    
  }
  
}
