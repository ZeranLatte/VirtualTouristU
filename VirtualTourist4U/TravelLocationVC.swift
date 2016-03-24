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
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
        
        //MARK: - Bugs: Fail to show any map annotation in a mapView from core data.
        let result = self.fetchedResultsController.fetchedObjects as! [MKAnnotation]
        print("Pin count: \(result.count)")
        self.mapView.addAnnotations(result)
        print("MapView annotation count: \(self.mapView.annotations.count)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

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
    


    func actionToAddPin(gestureRecognizer:UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let newCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        let pinDictionary = [
            "longitude": newCoord.longitude,
            "latidude": newCoord.latitude
        ]
        
        print("Long press to add a new pin")
        
        // Core Date init to persist pin object
        let _ = Pin(latitude: newCoord.latitude, longitude: newCoord.longitude, context: sharedContext)
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

        case .Delete:
            print("Calling mapView to remove a pin")
            
        default:
            return            
        }
    }
   


}

extension TravelLocationVC: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //        let identifier = "pin"
        //        var view: MKPinAnnotationView
        //        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
        //            dequeuedView.annotation = annotation
        //            view = dequeuedView
        //        } else {
        //            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        //            view.canShowCallout = true
        //            view.calloutOffset = CGPoint(x: -5, y: 5)
        //            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        //
        //        }
        //        view.backgroundColor = UIColor(red: 0.85, green: 0.79, blue: 0.71, alpha: 1)
        //        return view
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.canShowCallout = false
        
        return annotationView
        
    }
    
    // MARK: TODO
    // when a pin is tapped, go to photo album scene.
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Location View Controller: pin tapped -- \(view.annotation?.coordinate)")
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumVC") as! PhotoAlbumVC
        self.navigationController?.pushViewController(controller, animated: true)
    }

    
}

