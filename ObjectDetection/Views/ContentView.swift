//
//  ContentView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 28/03/2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ARViewModel()

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ARViewContainer(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        viewModel.startSession()
                    }
                    .onDisappear {
                        viewModel.stopSession()
                    }

                if !viewModel.sessionMessage.isEmpty {
                    withAnimation {
                        MessageOverlay(message: viewModel.sessionMessage)
                            .padding(.top, 25)
                            .transition(.opacity)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: HistoryView()) {
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
        .environment(\.managedObjectContext, DataController.shared.viewContext)
    }
}

#Preview {
    ContentView()
}



