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
    
    let mlModel: VNCoreMLModel
    
    init() {
        guard let model = try? VNCoreMLModel(for: YOLOv3Int8LUT(configuration: MLModelConfiguration()).model) else {
            fatalError("Failed to load ml model")
        }
        self.mlModel = model
    }
    
    lazy var coreMLRequest: VNCoreMLRequest = {
        return VNCoreMLRequest(model: mlModel, completionHandler: self.coreMlRequestHandler)
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
            let errorDetail = error.localizedDescription
            let enhancedError = RecognitionError.unexpectedError("Failed to perform image request: \(errorDetail)")
            self.complete(.failure(enhancedError))
            return
        }
    }
}

private extension ObjectDetectionService {
    
    func coreMlRequestHandler(_ request: VNRequest?, error: Error?) {
        if let error = error {
            let errorDetail = error.localizedDescription
            complete(.failure(RecognitionError.unexpectedError("Error during ML request: \(errorDetail)")))
            return
        }
        
        guard let results = request?.results as? [VNRecognizedObjectObservation] else {
            complete(.failure(RecognitionError.resultIsEmpty))
            return
        }
        
        guard let result = results.first(where: { $0.confidence > 0.8 }),
              let classification = result.labels.first else {
            complete(.failure(RecognitionError.lowConfidence))
            return
        }
        
        let response = Response(boundingBox: result.boundingBox,
                                classification: classification.identifier,
                                confidence: classification.confidence)
        complete(.success(response))
    }
    
    func complete(_ result: Result<Response, Error>) {
        DispatchQueue.main.async {
            self.completion?(result)
            self.completion = nil
        }
    }
}

extension ObjectDetectionService {
    struct Request {
        let pixelBuffer: CVPixelBuffer
    }
    
    struct Response {
        let boundingBox: CGRect
        let classification: String
        let confidence: Float
    }
}

extension UIDevice {
    var exifOrientation: UInt32 {
        switch orientation {
        case .portraitUpsideDown: return 8
        case .landscapeLeft: return 1
        case .landscapeRight: return 3
        default: return 6
        }
    }
}

enum RecognitionError: Error {
    case unableToInitializeCoreMLModel
    case invalidImageData
    case resultIsEmpty
    case lowConfidence
    case unexpectedError(String)
}
