//
//  PhotoAlbumVC.swift
//  VirtualTourist4U
//
//  Created by ZZZZeran on 3/3/16.
//  Copyright © 2016 Z Latte. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var mapView: MKMapView!
    var collectionView: UICollectionView!
    var newButton: UIButton!
    var region:  MKCoordinateRegion!
    var pin: Pin!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Core data fetch
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self
        
        let height = self.view.frame.height
        mapView = MKMapView()
        self.view.addSubview(mapView)
        mapView.setRegion(region, animated: true)
        mapView.centerCoordinate = pin.coordinate
        mapView.addAnnotation(self.pin)
        mapView.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view)
            make.centerX.equalTo(self.view)
            make.height.equalTo(height * 0.4)
            make.top.equalTo(self.view).offset(0)
        }

        initCollectionView()
        
        newButton = createButton()
        self.view.addSubview(newButton)
        newButton.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(0)
            make.height.equalTo(50)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    func initCollectionView() {
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        let cellWidth = (width-18)/3
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = cellSize
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 10
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.registerClass(PhotoAlbumCellCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.centerX.equalTo(self.view)
            make.height.equalTo(height * 0.6)
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

    // MARK: - UICollectionView delegate and datasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoAlbumCellCollectionViewCell
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        //
    }
    
    
    
    // MARK: - Core Data properties
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let request = NSFetchRequest(entityName: "Pin")
        
        request.sortDescriptors = []
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return controller
        
    }()
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
}


extension PhotoAlbumVC: NSFetchedResultsControllerDelegate {
    
    // MARK: - Core Data properties
    
    
    
    
}






