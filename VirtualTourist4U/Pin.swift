//
//  Pin.swift
//  VirtualTourist4U
//
//  Created by ZZZZeran on 3/4/16.
//  Copyright © 2016 Z Latte. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject, MKAnnotation {
    
    // MKAnnotation properties
    
    var coordinate: CLLocationCoordinate2D {
        get {
            
//            let privateMOC = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
//            privateMOC.parentContext = CoreDataStackManager.sharedInstance().managedObjectContext
//            
//            privateMOC.performBlock { () -> Void in
//                let coordinate = CLLocationCoordinate2DMake(self.latitude as CLLocationDegrees, self.longitude as CLLocationDegrees)
////                do {
////                    try privateMOC.save()
////                } catch {
////                    fatalError("Failure to save context: \(error)")
////                }
//
//            }
            let coordinate = CLLocationCoordinate2DMake(self.latitude as CLLocationDegrees, self.longitude as CLLocationDegrees)

            return coordinate

        
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    var title: String?
    var id: String?
    
    struct Keys {
        static let Longitude = "longitude"
        static let Latitude = "latitude"
        static let Pictures = "pictures"
    }

    // Managed by CoreDataStack
    @NSManaged var pictures: [Photo]
    @NSManaged var longitude: NSNumber
    @NSManaged var latitude: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(latitude: NSNumber, longitude: NSNumber, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        coordinate = CLLocationCoordinate2DMake(latitude as CLLocationDegrees, longitude as CLLocationDegrees)
    }
    
    
    

}
