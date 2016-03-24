//
//  PhotoAlbumVC.swift
//  VirtualTourist4U
//
//  Created by ZZZZeran on 3/3/16.
//  Copyright © 2016 Z Latte. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumVC: UIViewController {
    
    var mapView: MKMapView!
    var collectionView: UICollectionView!
    var newButton: UIButton!
    var centerLocation: CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let height = self.view.frame.height
        mapView = MKMapView()
        self.view.addSubview(mapView)
        mapView.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view)
            make.centerX.equalTo(self.view)
            make.height.equalTo(height * 0.4)
            make.top.equalTo(self.view).offset(0)
        }

        newButton = createButton()
        self.view.addSubview(newButton)
        newButton.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(0)
            make.height.equalTo(50)
        }
    }

    
    
    func createButton() -> UIButton {
        let button = UIButton()
        button.setTitle("New Collection", forState: .Normal)
        let color = UIColor(red: 0.35, green: 0.45, blue: 0.85, alpha: 1)
        button.setTitleColor(color, forState: .Normal)
        button.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.4)
        return button
    }
    
    //helper method specifying the rectangular region of map
    func centerMapLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 25000

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius*2.0, regionRadius*2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
