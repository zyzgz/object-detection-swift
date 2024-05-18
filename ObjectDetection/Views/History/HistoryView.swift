//
//  HistoryView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 08/05/2024.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.scannedObjects) { object in
                    HistoryCell(object: object)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            viewModel.selectObject(object)
                        }
                }
                .onDelete(perform: deleteObject)
            }
            .navigationTitle("Recent Scans")
            .listStyle(.plain)
            .alert(isPresented: $viewModel.isShowingAlert) {
                Alert(title: Text("Error"),
                      message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
                      dismissButton: .default(Text("OK")))
            }
            
            if viewModel.scannedObjects.isEmpty {
                Text("No scans available").foregroundColor(.secondary)
            }
        }
        .sheet(item: $viewModel.selectedObject) { item in
            HistoryDetailView(object: item)
        }
    }

    private func deleteObject(offsets: IndexSet) {
        viewModel.deleteObject(at: offsets)
    }
}
