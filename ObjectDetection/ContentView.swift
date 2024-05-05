//
//  ContentView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 28/03/2024.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
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

