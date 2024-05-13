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
    let container = NSPersistentContainer(name: "ScanItModel")
    
    init() {
        container.loadPersistentStores { desc, error in
            if let error = error {
                print("Failed to load the data \(error.localizedDescription)")
            }
        }
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("data saved")
        } catch {
            print("We could not save the data...")
        }
    }
    
    func addScannedObject(classification: String, confidence: Float, thumbnail: UIImage, context: NSManagedObjectContext) {
        let scannedObject = ScannedObject(context: context)
        scannedObject.id = UUID()
        scannedObject.date = Date()
        scannedObject.classification = classification
        scannedObject.confidence = confidence
        scannedObject.thumbnail = thumbnail.jpegData(compressionQuality: 1.0)
        
        save(context: context)
    }
}
