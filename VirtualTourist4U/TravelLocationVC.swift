//
//  ViewController.swift
//  VirtualTourist4U
//
//  Created by ZZZZeran on 3/3/16.
//  Copyright © 2016 Z Latte. All rights reserved.
//

import UIKit
import SnapKit
import MapKit
import CoreData

class TravelLocationVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    var mapView: MKMapView!
    var newPin: Pin!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Start Map view")
        
        
        // Core Data prepare
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
        
        loadMapView()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "actionToAddPin:")
        longPress.minimumPressDuration = 0.8
        mapView.addGestureRecognizer(longPress)
      
        //MARK: - Bugs: Fail to show any map annotation in a mapView from core data.
//        let pins = self.fetchedResultsController.fetchedObjects as! [Pin]
//        print(pins[1])
//        mapView.addAnnotations(pins)
        prepMapState()
        //print("Pin count: \(pins.count)")
        print("MapView annotation count: \(self.mapView.annotations.count)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear")

        let pins = self.fetchedResultsController.fetchedObjects as! [Pin]
        mapView.addAnnotations(pins)
        
//        mapView.addAnnotations(fetchAllPins())
//        print(fetchAllPins()[0].coordinate)
        print("MapView annotation count: \(self.mapView.annotations.count)")
       
    }
    
    func fetchAllPins() -> [Pin] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch _ {
            return [Pin]()
        }
    }
    
    func fetchAndAddPins() {
        let pins = fetchedResultsController.fetchedObjects
        if let array = pins as? [Pin] {
            for item in array {
                let pin = item as Pin
                mapView.addAnnotation(pin)
            }
        }
    }

    
    func loadMapView() {
        // init mapView and add
        mapView = MKMapView()
        view.addSubview(mapView)
        
        // set autolayouts
        mapView.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view)
            make.height.equalTo(self.view)
            make.center.equalTo(self.view)
        }
        
        //set delegate for mapView
        self.mapView.delegate = self
        
    }
    
   
    func actionToAddPin(sender:UIGestureRecognizer) {
        print("Long press to add a new pin")
        if sender.state != UIGestureRecognizerState.Began {
            return
        }
        let touchPoint = sender.locationInView(self.mapView)
        let newCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        switch sender.state {
        case .Began:
            print("Press began")
            newPin = Pin(latitude: newCoord.latitude, longitude: newCoord.longitude, context: sharedContext)
            print(newPin.coordinate)
        case .Ended:
            print("Press ended")
        default:
            // do nothing
            break
        }
        CoreDataStackManager.sharedInstance().saveContext()

        let pinDictionary = [
            "longitude": newCoord.longitude,
            "latidude": newCoord.latitude
        ]
//        let newAnotation = MKPointAnnotation()
//        newAnotation.coordinate = newCoord
//        newAnotation.title = "New Location"
//        newAnotation.subtitle = "New Subtitle"
        
    }
    
    // MARK: - Use NSCoder to save last viewd map state
    // File directory for last view map regiog/position
    var mapStateFilePath: String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("savedMapState").path!
    }
    
    func prepMapState() {
        if let mapStateDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(mapStateFilePath) as? [String: AnyObject] {
            let lon = mapStateDictionary["longitude"] as! CLLocationDegrees
            let lat = mapStateDictionary["latitude"] as! CLLocationDegrees
            let lonDelta = mapStateDictionary["longitudeDelta"] as! CLLocationDegrees
            let latDelta = mapStateDictionary["latitudeDelta"] as! CLLocationDegrees
            let mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(lat, lon), span: MKCoordinateSpanMake(latDelta, lonDelta))
            mapView.setRegion(mapRegion, animated: true)
        }
    }
    
    func saveMapState() {
        print("Saving map region/location")
        let mapDictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        NSKeyedArchiver.archiveRootObject(mapDictionary, toFile: mapStateFilePath)
    }

    
    // MARK: - Core Data properties
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let request = NSFetchRequest(entityName: "Pin")
        
        request.sortDescriptors = [NSSortDescriptor(key: "longitude", ascending: true)]
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return controller
        
    }()
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    // MARK: - Core Data NSFetchedResultsControllerDelegate methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("NSFetchedResultsController will change method")
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            
        case .Insert:
            print("Calling mapView to insert a new pin")
            mapView.addAnnotation(newPin)

        case .Delete:
            print("Calling mapView to remove a pin")
            
        default:
            return            
        }
    }
    
    
   


}

extension TravelLocationVC: MKMapViewDelegate {
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        //Use a dequed annotation view if possible, otherwise create a new one
        let identifier = "pinViewID"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView!.canShowCallout = false
            pinView?.animatesDrop = true
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
        
    }
    
    // MARK: TODO
    // when a pin is tapped, go to photo album scene.
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Location View Controller: pin tapped -- \(view.annotation?.coordinate)")
        saveMapState()
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumVC") as! PhotoAlbumVC
        controller.region = mapView.region
        controller.pin = view.annotation as! Pin
        self.navigationController?.pushViewController(controller, animated: true)
    }

    
}

