//
//  ContentView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 28/03/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CameraView()
            .frame(maxWidth: .infinity, maxHeight: 300)
//        TabView {
//            CameraView()
//                .tabItem { Label("Rozpoznaj", systemImage: "camera.viewfinder") }
//            
//            HistoryView()
//                .tabItem { Label("Historia", systemImage: "clock.arrow.circlepath") }
//        }
    }
}

#Preview {
    ContentView()
}

