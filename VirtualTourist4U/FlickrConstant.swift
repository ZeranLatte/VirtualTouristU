//
//  FlickerConstant.swift
//  VirtualTourist4U
//
//  Created by ZZZZeran on 3/23/16.
//  Copyright © 2016 Z Latte. All rights reserved.
//

import Foundation

extension FlickrAPI {
    
    
    // MARK: Constants
    struct Constants {
        
        static let FlickrAPIKey : String = "ae86539142323875ee4c82a826c6340f"
        static let FlickrBaseURLSecure : String = "https://api.flickr.com/services/rest/"
        
        static let EXTRAS = "url_m"
        static let SAFE_SEARCH = "1"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"
        static let CONTENT_TYPE = "1"
        static let NUM_PHOTOS = 21
        static let PHOTOS_PER_PAGE = 500
        
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
        
    }
    
    // MARK: Methods
    struct Methods {
        
        static let photoSearchMethod = "flickr.photos.search"
        
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        static let bbox = "bbox"
        static let safeSearch = "safe_search"
        static let contentType = "content_type"
        static let extras = "extras"
        static let perPage = "per_page"
        
    }

}