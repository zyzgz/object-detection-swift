//
//  ContentView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 28/03/2024.
//

import SwiftUI

struct ContentView: View {
    
//    @State private var recognizedObject = ""
    
    var body: some View {
//        ARViewContainer()
//            .edgesIgnoringSafeArea(.all)
        NavigationView {
            VStack {
                ARViewContainer()
                           .edgesIgnoringSafeArea(.all)
            }
            .navigationTitle("🕵🏻‍♂️ Skaner")
        }
    }
}

#Preview {
    ContentView()
}

