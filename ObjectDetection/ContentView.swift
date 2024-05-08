//
//  ContentView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 28/03/2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var sessionMessage: String = "Looking for surfaces..."
    
    var body: some View {
        NavigationView {
            VStack {
                ARViewContainer(sessionMessage: $sessionMessage)
                    .edgesIgnoringSafeArea(.all)
                
                Text(sessionMessage)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    ContentView()
}

