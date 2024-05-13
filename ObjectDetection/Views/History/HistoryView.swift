//
//  HistoryView.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 08/05/2024.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var scannedObjects: FetchedResults<ScannedObject>

    @State private var selectedObject: ScannedObject? = nil
    @State private var errorMessage: String?
    @State private var isShowingAlert = false

    var body: some View {
        NavigationView {
            List {
                ForEach(scannedObjects) { object in
                    HistoryCellView(object: object)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            self.selectedObject = object
                        }
                }
                .onDelete(perform: deleteObject)
            }
            .navigationTitle("Recent Scans")
            .listStyle(.plain)
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text("Error"),
                      message: Text(errorMessage ?? "An unknown error occurred"),
                      dismissButton: .default(Text("OK")))
            }
            
            if scannedObjects.isEmpty {
                if managedObjectContext.hasChanges {
                    ProgressView("Loading...")
                } else {
                    Text("No scans available").foregroundColor(.secondary)
                }
            }
        }
        .sheet(item: $selectedObject, content: { item in
            HistoryDetailView(object: item)
        })
    }

    private func deleteObject(offsets: IndexSet) {
        withAnimation {
            offsets.map { scannedObjects[$0] }
                .forEach(managedObjectContext.delete)

            do {
                try managedObjectContext.save()
            } catch {
                let nsError = error as NSError
                errorMessage = "Unresolved error: \(nsError), \(nsError.userInfo)"
                isShowingAlert = true
            }
        }
    }
}

#Preview {
    HistoryView()
}
