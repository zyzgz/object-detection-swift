//
//  CameraVC.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 28/03/2024.
//

import Foundation
import AVFoundation
import UIKit

protocol CameraVCDelegate: AnyObject {
    func captured(image: UIImage)
}

// Ta klasa jest odpowiedzialna za zarządzanie przechwytywaniem obrazu z kamery i przekazywaniem go do delegata.

final class CameraVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: CameraVCDelegate?
       
    override func viewDidLoad() {
        super.viewDidLoad()
           
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            fatalError("Brak dostępu do kamery.")
        }
           
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print(error)
            return
        }
           
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoOutput)
           
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        if let videoPreviewLayer = videoPreviewLayer {
            view.layer.addSublayer(videoPreviewLayer)
        }
           
        captureSession.startRunning()
    }
       
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let uiImage = UIImage(ciImage: ciImage)
        delegate?.captured(image: uiImage)
    }
}

