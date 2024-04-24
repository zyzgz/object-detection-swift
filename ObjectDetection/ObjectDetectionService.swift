//
//  ObjectDetectionService.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 21/04/2024.
//

import UIKit
import CoreML
import Vision
import SceneKit

class ObjectDetectionService {
    
    let model: VNCoreMLModel
    
    init() {
        guard let resnet50Model = try? VNCoreMLModel(for: Resnet50(configuration: MLModelConfiguration()).model) else {
            fatalError("Failed to load ResNet50 model")
        }
        self.model = resnet50Model
    }
    
    lazy var coreMLRequest: VNCoreMLRequest = {
        return VNCoreMLRequest(model: model,
                               completionHandler: self.coreMlRequestHandler)
    }()
    
    private var completion: ((Result<Response, Error>) -> Void)?
    
    func detect(on request: Request, completion: @escaping (Result<Response, Error>) -> Void) {
        self.completion = completion
            
        let orientation = CGImagePropertyOrientation(rawValue:  UIDevice.current.exifOrientation) ?? .up
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: request.pixelBuffer,
                                                            orientation: orientation)
            
        do {
            try imageRequestHandler.perform([coreMLRequest])
        } catch {
            self.complete(.failure(error))
            return
        }
    }
}

private extension ObjectDetectionService {
    func coreMlRequestHandler(_ request: VNRequest?, error: Error?) {
        if let error = error {
            complete(.failure(error))
            return
        }
        
        guard let request = request, let results = request.results as? [VNRecognizedObjectObservation] else {
            complete(.failure(RecognitionError.resultIsEmpty))
            return
        }
        
        guard let result = results.first(where: { $0.confidence > 0.8 }),
            let classification = result.labels.first else {
                complete(.failure(RecognitionError.lowConfidence))
                return
        }
        
        let response = Response(boundingBox: result.boundingBox,
                                classification: classification.identifier)
        
        complete(.success(response))
    }
    
    func complete(_ result: Result<Response, Error>) {
        DispatchQueue.main.async {
            self.completion?(result)
            self.completion = nil
        }
    }
}

extension UIDevice {
    var exifOrientation: UInt32 {
        let exifOrientation: DeviceOrientation
        enum DeviceOrientation: UInt32 {
            case top0ColLeft = 1
            case top0ColRight = 2
            case bottom0ColRight = 3
            case bottom0ColLeft = 4
            case left0ColTop = 5
            case right0ColTop = 6
            case right0ColBottom = 7
            case left0ColBottom = 8
        }
        switch orientation {
        case .portraitUpsideDown: exifOrientation = .left0ColBottom
        case .landscapeLeft: exifOrientation = .top0ColLeft
        case .landscapeRight: exifOrientation = .bottom0ColRight
        default: exifOrientation = .right0ColTop
        }
        return exifOrientation.rawValue
    }
}

enum RecognitionError: Error {
    case unableToInitializeCoreMLModel
    case resultIsEmpty
    case lowConfidence
}

extension ObjectDetectionService {
    struct Request {
        let pixelBuffer: CVPixelBuffer
    }
    
    struct Response {
        let boundingBox: CGRect
        let classification: String
    }
}
