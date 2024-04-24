//
//  CameraVC.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 28/03/2024.
//

import UIKit
import AVFoundation

enum CameraError: String {
    case invalidCameraAccess = "Brak dostępu do kamery. Sprawdź ustawienia prywatności."
    case unableToCaptureInput = "Nie można przechwycić danych wejściowych z kamery."
    case recognitionError = "Błąd rozpoznawania obiektu."
    case invalidPreviewLayer = "Podgląd kamery jest nieprawidłowy."
}

protocol CameraVCDelegate: AnyObject {
    func captured(image: CVPixelBuffer)
    func cameraErrorOccurred(_ error: CameraError)  
}

final class CameraVC: UIViewController {
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var cameraDelegate: CameraVCDelegate!
    
    init(cameraDelegate: CameraVCDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.cameraDelegate = cameraDelegate
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let previewLayer = previewLayer else {
            cameraDelegate.cameraErrorOccurred(.invalidPreviewLayer)
            return
        }
        
        previewLayer.frame = view.layer.bounds
    }
    
    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            cameraDelegate?.cameraErrorOccurred(.invalidCameraAccess)
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            cameraDelegate?.cameraErrorOccurred(.unableToCaptureInput)
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            cameraDelegate?.cameraErrorOccurred(.unableToCaptureInput)
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
    }
    
}

extension CameraVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                cameraDelegate?.cameraErrorOccurred(.recognitionError)
                return
            }
            
            cameraDelegate?.captured(image: pixelBuffer)
        }
}
