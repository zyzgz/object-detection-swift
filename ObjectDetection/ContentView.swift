//
//  ContentView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 28/03/2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var sessionMessage: String = "Looking for surfaces..."
    @State private var scannedObjects: [ScannedObject] = []
    @State private var isARSessionActive = true

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ARViewContainer(sessionMessage: $sessionMessage,
                                scannedObjects: $scannedObjects,
                                isSessionActive: $isARSessionActive)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        isARSessionActive = true
                    }
                    .onDisappear {
                        isARSessionActive = false
                    }

                if !sessionMessage.isEmpty {
                    withAnimation {
                        MessageOverlay(message: sessionMessage)
                            .padding(.top, 25)
                            .transition(.opacity)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: HistoryView(scannedObjects: scannedObjects)) {
                            Image(systemName: "clock.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}



