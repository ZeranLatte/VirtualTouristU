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

class TravelLocationVC: UIViewController, NSFetchedResultsControllerDelegate, PinPickerDelegate {
    
    var mapView: MKMapView!
    var mapViewDelegate: MapViewDelegate?
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
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
        
        
        let result = self.fetchedResultsController.fetchedObjects as! [MKAnnotation]
        print("Pin count: \(result.count)")
        self.mapView.addAnnotations(result)
        print("MapView annotation count: \(self.mapView.annotations.count)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        let result = self.fetchedResultsController.fetchedObjects as! [MKAnnotation]
//        print("Pin count: \(result.count)")
//        self.mapView.addAnnotations(result)
        print("MapView annotation count: \(self.mapView.annotations.count)")
    }
    
    
    
    // MARK: - callback method from PinPickerDelegate
    func pinTappedAction(picker: MapViewDelegate, pin: String) {
        print("Location View Controller: pin tapped -- \(pin)")
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumVC") as! PhotoAlbumVC
        self.navigationController?.pushViewController(controller, animated: true)
        
        
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
        //mapViewDelegate = (mapView: mapView, coreDataContext: sharedContext)
        //pinPickDelegate
        
        mapViewDelegate = MapViewDelegate(delegate: self)
        self.mapView.delegate = mapViewDelegate
    }
    
    func centerMapLocation(location: CLLocation) {
        
        let regionRadius: CLLocationDistance = 25000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius*2.0, regionRadius*2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    


    func actionToAddPin(gestureRecognizer:UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let newCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        let pinDictionary = [
            "longitude": newCoord.longitude,
            "latidude": newCoord.latitude
        ]
        
        print("Long press to add a new pin")
        // Core Date init to persist pin object
        //let _ = Pin(latitude: newCoord.latitude, longitude: newCoord.longitude, context: sharedContext)
        //CoreDataStackManager.sharedInstance().saveContext()
        

        
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
            //self.mapViewDelegate?.InsertPin(anObject as! Pin)

        case .Delete:
            print("Calling mapView to remove a pin")
            
        default:
            return            
        }
    }
   


}

