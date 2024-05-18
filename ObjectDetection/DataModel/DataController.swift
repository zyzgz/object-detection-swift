//
//  DataController.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 12/05/2024.
//

import Foundation
import CoreData
import UIKit

class DataController: ObservableObject {
    
    static let shared = DataController()
    let container: NSPersistentContainer
    
    @Published var errorMessage: String?
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    init() {
        container = NSPersistentContainer(name: "ScanItModel")
        
        container.loadPersistentStores { desc, error in
            if let error = error {
                self.errorMessage = "Failed to load the data \(error.localizedDescription)"
            }
        }
    }
    
    func save() {
        do {
            try viewContext.save()
        } catch {
            self.errorMessage = "We could not save the data..."
        }
    }
    
    func addScannedObject(classification: String, confidence: Float, thumbnail: UIImage) {
        let scannedObject = ScannedObject(context: viewContext)
        scannedObject.id = UUID()
        scannedObject.date = Date()
        scannedObject.classification = classification
        scannedObject.confidence = confidence
        scannedObject.thumbnail = thumbnail.jpegData(compressionQuality: 1.0)
        
        save()
    }
    
    func fetchScannedObjects() -> [ScannedObject] {
         let fetchRequest: NSFetchRequest<ScannedObject> = ScannedObject.fetchRequest()
         fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ScannedObject.date, ascending: false)]
         
         do {
             return try viewContext.fetch(fetchRequest)
         } catch {
             self.errorMessage = "Failed to fetch scanned objects: \(error.localizedDescription)"
             return []
         }
     }
     
     func deleteObject(object: ScannedObject) {
         viewContext.delete(object)
         save()
     }
}
