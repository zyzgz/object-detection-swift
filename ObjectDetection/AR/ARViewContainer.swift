//
//  ARViewContainer.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 24/04/2024.
//

import SwiftUI
import ARKit
import SceneKit
import AVKit
import CoreData

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel

    let objectDetectionService = ObjectDetectionService()
    let throttlerService = ThrottlerService(minimumDelay: 1, queue: .global(qos: .userInteractive))
    var sceneView = ARSCNView()

    func makeUIView(context: Context) -> ARSCNView {
        sceneView.delegate = context.coordinator
        sceneView.session.delegate = context.coordinator
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [.showFeaturePoints]

        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if viewModel.isARSessionActive != context.coordinator.cachedIsSessionActive {
            manageSession()
            context.coordinator.cachedIsSessionActive = viewModel.isARSessionActive
        }
    }

    func manageSession() {
        if viewModel.isARSessionActive {
            startSession()
        } else {
            stopSession()
        }
    }

    func startSession(resetTracking: Bool = false) {
        guard ARWorldTrackingConfiguration.isSupported else {
            assertionFailure("ARKit is not supported")
            return
        }

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        if resetTracking {
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        } else {
            sceneView.session.run(configuration)
        }
    }

    func stopSession() {
        sceneView.session.pause()
    }

    func makeCoordinator() -> ARCoordinator {
        ARCoordinator(objectDetectionService: objectDetectionService,
                      throttlerService: throttlerService,
                      sceneView: sceneView,
                      sessionMessage: $viewModel.sessionMessage,
                      isSessionActive: $viewModel.isARSessionActive)
    }
}
