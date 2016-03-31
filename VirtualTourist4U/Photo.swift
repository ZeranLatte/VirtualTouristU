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
    @NSManaged var imgUrl: String?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(imageUrlStr: String, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        imgUrl = imageUrlStr
        let url = NSURL(string: imageUrlStr)!
        if let path = url.lastPathComponent {
            imgPath = "/\(path)"
        }
    }
    
    override func prepareForDeletion() {
        
        if let fileName = imgPath {
            if let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
                let pathArray = [dirPath, fileName]
                print("pathArray: \(pathArray)")
                let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
                do {
                    
                    try NSFileManager.defaultManager().removeItemAtURL(fileURL)
                    
                } catch {
                    
                }
            }
        }
        
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
