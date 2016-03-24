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
    
    // File directory for last view map regiog/position
    var file: String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("savedLocation").path!
    }
    
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
        let result = self.fetchedResultsController.fetchedObjects as! [Pin]
        for pin in result {
            mapView.addAnnotation(pin)
        }
        
        print("Pin count: \(result.count)")
        print("MapView annotation count: \(self.mapView.annotations.count)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let result = self.fetchedResultsController.fetchedObjects as! [MKAnnotation]
        print("Pin count: \(result.count)")

        print("MapView annotation count: \(self.mapView.annotations.count)")
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
    
    func centerMapLocation(location: CLLocation) {
        
        let regionRadius: CLLocationDistance = 25000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius*2.0, regionRadius*2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func saveMapState() {
        print("Saving map region/location")
        let mapDictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        NSKeyedArchiver.archiveRootObject(mapDictionary, toFile: file)
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
        case .Ended:
            CoreDataStackManager.sharedInstance().saveContext()
            print("Press ended")
        default:
            // do nothing
            break
        }

        let pinDictionary = [
            "longitude": newCoord.longitude,
            "latidude": newCoord.latitude
        ]
        
        
        // Core Date init to persist pin object
//        let _ = Pin(latitude: newCoord.latitude, longitude: newCoord.longitude, context: sharedContext)
        
        let newAnotation = MKPointAnnotation()
        newAnotation.coordinate = newCoord
        newAnotation.title = "New Location"
        newAnotation.subtitle = "New Subtitle"
        mapView.addAnnotation(newAnotation)
        
    }
    
    // MARK: - Core Data related functions and properties
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let request = NSFetchRequest(entityName: "Pin")
        
        request.sortDescriptors = []
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return controller
        
    }()
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("NSFetchedResultsController will change method")
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            
        case .Insert:
            print("Calling mapView to insert a new pin")

        case .Delete:
            print("Calling mapView to remove a pin")
            
        default:
            return            
        }
    }
   


}

extension TravelLocationVC: MKMapViewDelegate{
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        //Use a dequed annotation view if possible, otherwise create a new one
        let identifier = "Pin"
        var view: MKPinAnnotationView
        
        if let dequeuedAnnotatationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
            
            dequeuedAnnotatationView.annotation = annotation
            view = dequeuedAnnotatationView
            
        } else {
            
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = false
            view.animatesDrop = true
            view.draggable = false
        }
        
        return view
        
    }
    
    // MARK: TODO
    // when a pin is tapped, go to photo album scene.
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Location View Controller: pin tapped -- \(view.annotation?.coordinate)")
        saveMapState()
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumVC") as! PhotoAlbumVC
        self.navigationController?.pushViewController(controller, animated: true)
    }

    
}

