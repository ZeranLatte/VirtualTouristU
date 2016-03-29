//
//  FlickerAPI.swift
//  VirtualTourist4U
//
//  Created by ZZZZeran on 3/23/16.
//  Copyright © 2016 Z Latte. All rights reserved.
//
import Foundation
import CoreData

class FlickrAPI: NSObject {
    
    
    //MARK: Properties
    
    /* Shared Session */
    var session: NSURLSession
    
    
    //MARK: Initializer
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - Shared Instance
    class func sharedInstance() -> FlickrAPI {
        
        struct Singleton {
            static var sharedInstance = FlickrAPI()
        }
        
        return Singleton.sharedInstance
    }
    

    
    // MARK: - GET
    
    // Return a number of random Picture objects from Flickr matching the lat and long coordinates - number to return specified in constant NUM_PHOTOS up to the max number returned
    func getPicturesFromPin(pin: Pin, completionHandler: (result: [[String: String]]?, error: NSError?) -> Void)  {
        
        let randomPageNum = Int(arc4random_uniform(100_000))
        
        let methodArguments: [String: AnyObject]  = [
            "method" : FlickrAPI.Methods.photoSearchMethod,
            FlickrAPI.ParameterKeys.ApiKey : FlickrAPI.Constants.FlickrAPIKey,
            "safe_search" : FlickrAPI.Constants.SAFE_SEARCH,
            "content_type" : FlickrAPI.Constants.CONTENT_TYPE,
            "extras" : FlickrAPI.Constants.EXTRAS,
            "format" : FlickrAPI.Constants.DATA_FORMAT,
            "nojsoncallback" : FlickrAPI.Constants.NO_JSON_CALLBACK,
            "per_page" : FlickrAPI.Constants.PHOTOS_PER_PAGE,
            "page" : randomPageNum,
            "lat" : pin.coordinate.latitude,
            "lon" : pin.coordinate.longitude,
            "bbox" : createBoundingBoxString(pin.coordinate.latitude, long: pin.coordinate.longitude)
        ]
        
        let session = NSURLSession.sharedSession()
        let urlString = Constants.FlickrBaseURLSecure + FlickrAPI.escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your Flickr search request: \(error)")
                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                completionHandler(result: nil, error: nil)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(result: nil, error: nil)
                return
            }
            
            /* Parse the data! */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            print(parsedResult)
            
            // GUARD: Did Flickr return an error?
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                completionHandler(result: nil, error: nil)
                return
            }
            
            // GUARD: Is "photos" key in our result?
            guard let resultsDictionary = parsedResult["photos"] as? NSDictionary else {
                print("Cannot find keys 'photos' in \(parsedResult)")
                completionHandler(result: nil, error: nil)
                return
            }
            
            // GUARD: Is "photo" key in the photosDictionary?
            guard let photosDictionary = resultsDictionary["photo"] as? [[String: AnyObject]] else {
                print("Cannot find key 'photo' in \(resultsDictionary)")
                completionHandler(result: nil, error: nil)
                return
            }
            
            // Pick random images from the results
            let totalReturnedImages = photosDictionary.count
            
            let numberOfImages = min(totalReturnedImages, Constants.NUM_PHOTOS)
            let imageIndexArray = self.generateRandomIndexes(numberOfImages)
            
            var returnArray = [[String : String]]()
            
            for index in imageIndexArray {
                let urlString = photosDictionary[index]["url_q"] as! String
                let dictionary = ["url_q":urlString]
                returnArray.append(dictionary)
            }
            
            completionHandler(result: returnArray, error: nil)
            
        }
        
        task.resume()
    }
    
    //This function returns a task to download photo data given the photo's Flickr URL
    func imgFromURL (imgUrlStr: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionDataTask {
        
        let imgUrl = NSURL(string: imgUrlStr)!
        let request = NSURLRequest(URL: imgUrl)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if let _ = error {
                completionHandler(imageData: nil, error: NSError(domain: "imgFromURL", code: 0, userInfo: [NSLocalizedDescriptionKey : "error with photo download request"]))
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        return task
    }
    
    // MARK: - Helper functions
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    
    /* Helper: Create bounding box string */
    func createBoundingBoxString(lat: Double, long: Double) -> String {
        
        /* Ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(long - Constants.BOUNDING_BOX_HALF_WIDTH, Constants.LON_MIN)
        let bottom_left_lat = max(lat - Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MIN)
        let top_right_lon = min(long + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LON_MAX)
        let top_right_lat = min(lat + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    func generateRandomIndexes(numberOfIndexes: Int) -> [Int] {
        
        var randomNumArray: [Int] = []
        var i = 0
        while randomNumArray.count < numberOfIndexes {
            i++
            let rand = Int(arc4random_uniform(UInt32(numberOfIndexes)))
            for(var ii = 0; ii < numberOfIndexes; ii++){
                if !randomNumArray.contains(rand){
                    randomNumArray.append(rand)
                }
            }
        }
        return randomNumArray
    }
    
    
    
    
}

