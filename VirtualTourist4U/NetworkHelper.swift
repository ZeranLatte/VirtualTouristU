//
//  NetworkHelper.swift
//  VirtualTourist4U
//
//  Created by ZZZZeran on 3/4/16.
//  Copyright © 2016 Z Latte. All rights reserved.
//

import UIKit

class NetworkHelper: NSObject {
    
    var session: NSURLSession
    
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    
    // MARK: - Shared Image Cache
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    
    // MARK: - Shared Instance for project use
    class func sharedInstance() -> NetworkHelper {
        struct Singleton {
            static var sharedInstance = NetworkHelper()
        }
        
        return Singleton.sharedInstance
    }
    
    

}
