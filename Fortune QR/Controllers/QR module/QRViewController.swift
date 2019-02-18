//
//  QRViewController.swift
//  Fortune QR
//
//  Created by Sarvad shetty on 2/2/19.
//  Copyright © 2019 Sarvad shetty. All rights reserved.
//

import UIKit
import AVFoundation
import BRYXBanner

class QRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK: - Variables
    var dataToPass:String?
    
    //creating a session
    let videoSession = AVCaptureSession()
    var videoLayer = AVCaptureVideoPreviewLayer()
    var scannerFrame:UIView?
    var barcodeScanningFrame:UIView?
    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                              AVMetadataObject.ObjectType.code39,
                              AVMetadataObject.ObjectType.code39Mod43,
                              AVMetadataObject.ObjectType.code93,
                              AVMetadataObject.ObjectType.code128,
                              AVMetadataObject.ObjectType.ean8,
                              AVMetadataObject.ObjectType.ean13,
                              AVMetadataObject.ObjectType.aztec,
                              AVMetadataObject.ObjectType.pdf417,
                              AVMetadataObject.ObjectType.itf14,
                              AVMetadataObject.ObjectType.dataMatrix,
                              AVMetadataObject.ObjectType.interleaved2of5,
                              AVMetadataObject.ObjectType.qr]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        checkConnection { (status, statusCode) in
            if statusCode == 404{
                print("herererere")
                let title = "No connection"
                let subtitle = "Connect to Internet,then restart app"
                let banner = Banner(title: title, subtitle: subtitle, backgroundColor: .red)
                banner.springiness = .slight
                banner.position = .top
                banner.dismissesOnTap = false
                banner.show()
            }else{
                print("connection existing")
            }
        }
        ScannerSetup()
    }
    
    //MARK: - Scanner
    func ScannerSetup(){
        //capture device type
        let captureDeviceType = AVCaptureDevice.default(for: .video)
        //taking in input
        do{
            //creating an input instance from camera to add to session
            let input = try AVCaptureDeviceInput.init(device: captureDeviceType!)
            videoSession.addInput(input)
        }catch{
            print("error capturing input")
        }
        
        //output from metadata
        let output = AVCaptureMetadataOutput()
        videoSession.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = supportedCodeTypes
        
        //adding video layer to uiview
        videoLayer = AVCaptureVideoPreviewLayer(session: videoSession)
        videoLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoLayer)
        
        //start running
        videoSession.startRunning()
        
        //for the border
        scannerFrame = UIView()
        if let barcodeFrame = scannerFrame{
            barcodeFrame.layer.borderColor = UIColor.green.cgColor
            barcodeFrame.layer.borderWidth = 4
            barcodeFrame.frame = view.layer.bounds
            view.addSubview(barcodeFrame)
            view.bringSubviewToFront(barcodeFrame)
        }
    }
    
    //MARK: AVCaptureMetadataOutputObjectsDelegate function
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0{
            scannerFrame?.bounds = CGRect.zero
            return
        }
        
        let metaObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metaObject.type){
            let objectBounds = videoLayer.transformedMetadataObject(for: metaObject)
            scannerFrame?.bounds = objectBounds!.bounds
            let data = metaObject.stringValue!
            dataToPass = data
            self.videoSession.stopRunning()
            self.performSegue(withIdentifier: "backToMain", sender: self)
        }
    }
    
    
}
