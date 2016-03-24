//
//  Picture.swift
//  VirtualTourist4U
//
//  Created by ZZZZeran on 3/4/16.
//  Copyright © 2016 Z Latte. All rights reserved.
//

import UIKit
import CoreData


class Photo: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    @NSManaged var pin: Pin?
    @NSManaged var imgPath: String?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(imagePath: String, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Picture", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        imgPath = imagePath
    }
    
    var image: UIImage? {
        
        get {
            return NetworkHelper.Caches.imageCache.imageWithIdentifier(imgPath)
        }
        
        set {
            NetworkHelper.Caches.imageCache.storeImage(newValue, withIdentifier: imgPath!)
        }
    }

}
