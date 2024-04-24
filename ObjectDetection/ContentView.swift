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
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
//        NavigationView {
//            VStack {
//                CameraView(recognizedObject: $recognizedObject)
//                    .frame(maxWidth: .infinity, maxHeight: 500)
//                
//                Text(recognizedObject.isEmpty ? "Brak rozpoznanych obiektów" : recognizedObject)
//                    .bold()
//                    .font(.title2)
//                    .padding()
//            }
//            .navigationTitle("🕵🏻‍♂️ Skaner")
//        }
    }
}

#Preview {
    ContentView()
}

