//
//  CustomARView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 21/04/2024.
//

import ARKit
import RealityKit
import SwiftUI
import SceneKit

class CustomARView: ARView {
    
    let objectDetectionService = ObjectDetectionService()
    let throttler = Throttler(minimumDelay: 1, queue: .global(qos: .userInteractive))
    let sceneView = ARSCNView()
    var sessionInfoLabel = UILabel()
    var lastLocation: SCNVector3?
    var isLoopShouldContinue = true
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    dynamic required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
        
    func startSession(resetTracking: Bool = false) {
        guard ARWorldTrackingConfiguration.isSupported else {
            assertionFailure("ARKit is not supported")
            return
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // WTFWTFWTFWTFWTFWTFWTFWTFWTFWTFWTFWTFWTF
        
//        sceneView.delegate = self
//        sceneView.session.delegate = self
//        sceneView.scene = SCNScene()
//        sceneView.session.delegate = self
        
//        if resetTracking {
//            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//        } else {
//            sceneView.session.run(configuration)
//        }
        
        print("SceneView: ", sceneView)
    }

        
    func stopSession() {
        sceneView.session.pause()
    }
    
    func loopObjectDetection() {
         throttler.throttle { [weak self] in
             guard let self = self else { return }
             
             if self.isLoopShouldContinue {
                 self.performDetection()
             }
             self.loopObjectDetection()
         }
    }
    
    func performDetection() {
        guard let pixelBuffer = sceneView.session.currentFrame?.capturedImage else { return }
            
        objectDetectionService.detect(on: .init(pixelBuffer: pixelBuffer)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let rectOfInterest = VNImageRectForNormalizedRect(
                    response.boundingBox,
                    Int(self.sceneView.bounds.width),
                    Int(self.sceneView.bounds.height))
                self.addAnnotation(rectOfInterest: rectOfInterest,
                                    text: response.classification)
                
            case .failure(_):
                break
            }
        }
    }
    
    func addAnnotation(rectOfInterest rect: CGRect, text: String) {
        let point = CGPoint(x: rect.midX, y: rect.midY)
               
        let scnHitTestResults = sceneView.hitTest(point,
                                                options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue])
        guard !scnHitTestResults.contains(where: { $0.node.name == BubbleNode.name }) else { return }
               
        guard let raycastQuery = sceneView.raycastQuery(from: point,
                                                        allowing: .existingPlaneInfinite,
                                                        alignment: .horizontal),
        let raycastResult = sceneView.session.raycast(raycastQuery).first else { return }
        let position = SCNVector3(raycastResult.worldTransform.columns.3.x,
                                  raycastResult.worldTransform.columns.3.y,
                                  raycastResult.worldTransform.columns.3.z)

        guard let cameraPosition = sceneView.pointOfView?.position else { return }
        let distance = (position - cameraPosition).length()
        guard distance <= 0.5 else { return }
               
        let bubbleNode = BubbleNode(text: text)
        bubbleNode.worldPosition = position
               
        sceneView.prepare([bubbleNode]) { [weak self] success in
            if success {
                self?.sceneView.scene.rootNode.addChildNode(bubbleNode)
            }
        }
    }
    
    func onSessionUpdate(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
           let message: String
           
           switch trackingState {
           case .normal where frame.anchors.isEmpty:
               message = "Move the device around to detect horizontal and vertical surfaces."
               
           case .notAvailable:
               message = "Tracking unavailable."
               
           case .limited(.excessiveMotion):
               message = "Tracking limited - Move the device more slowly."
               
           case .limited(.insufficientFeatures):
               message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
               
           case .limited(.initializing):
               message = "Initializing AR session."
               
           default:
               message = ""
               isLoopShouldContinue = true
               loopObjectDetection()
           }
    
           sessionInfoLabel.text = message
           sessionInfoLabel.isHidden = message.isEmpty
    }
}

extension CustomARView: ARSessionDelegate {
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        guard let frame = session.currentFrame else { return }
        onSessionUpdate(for: frame, trackingState: camera.trackingState)
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        onSessionUpdate(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        onSessionUpdate(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let transform = SCNMatrix4(frame.camera.transform)
        let orientation = SCNVector3(-transform.m31, -transform.m32, transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = orientation + location
        
        if let lastLocation = lastLocation {
            let speed = (lastLocation - currentPositionOfCamera).length()
            isLoopShouldContinue = speed < 0.0025
        }
        lastLocation = currentPositionOfCamera
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        sessionInfoLabel.text = "Session interruption ended"
        startSession(resetTracking: true)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        sessionInfoLabel.text = "Session error: \(error.localizedDescription)"
    }
}

extension CustomARView: ARSCNViewDelegate { }

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
}

func -(l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
}

func +(l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3(l.x + r.x, l.y + r.y, l.z + r.z)
}

func /(l: SCNVector3, r: Float) -> SCNVector3 {
    return SCNVector3(l.x / r, l.y / r, l.z / r)
}
