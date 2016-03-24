//
//  MapViewDelegate.swift
//  VirtualTourist4U
//
//  Created by ZZZZeran on 3/3/16.
//  Copyright © 2016 Z Latte. All rights reserved.
//

import UIKit
import MapKit
import CoreData

protocol PinPickerDelegate: class {
    func pinTappedAction(picker: MapViewDelegate, pin: String)
}

class MapViewDelegate: NSObject, MKMapViewDelegate {
    
    
    var pinPickDelegate: PinPickerDelegate?

    
    
    init(delegate: PinPickerDelegate ) {
        //self.mapView = mapView
        self.pinPickDelegate = delegate
    }
    
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
        print("Map view delegate: did select annotationView")
        print("Alert the delegate which is Location VC  ---")
        pinPickDelegate?.pinTappedAction(self, pin: view.description)
        
    }
    
    
    
    func InsertPin(pin: Pin) {
        print("MapView Delegate: inserting a pin")
        //mapView.addAnnotation(pin)
    }
    
    
    
   

}
