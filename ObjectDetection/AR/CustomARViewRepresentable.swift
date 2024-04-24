//
//  CustomARViewRepresentable.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 22/04/2024.
//

import SwiftUI
import ARKit

struct CustomARViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> CustomARView {
        let customARView = CustomARView()
        customARView.startSession()
        return customARView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
}
