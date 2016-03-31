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
    var newOrDeleteButton: UIButton!
    var region:  MKCoordinateRegion!
    var pin: Pin!
    var deleteEnabled = false
    
    private var pageNumber: Int?
    
    
    private var selectedIndexes = [NSIndexPath]()
    private var insertedIndexPaths: [NSIndexPath]!
    private var deletedIndexPaths: [NSIndexPath]!
    private var updatedIndexPaths: [NSIndexPath]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Core data fetch
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self
        
        // init simple mapview
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
        
        // init collectionView
        initCollectionView()
        
        // 
        newOrDeleteButton = createButton()
        self.view.addSubview(newOrDeleteButton)
        newOrDeleteButton.addTarget(self, action: "buttonAction:", forControlEvents: .TouchUpInside)
        newOrDeleteButton.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(0)
            make.height.equalTo(50)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // if the pin's photo array is empty, try getting the photos
        if pin.pictures.isEmpty {
            pageNumber = 1
            self.getFlickrPhotos(pageNumber!)
        } else {
            pageNumber = pin.pictures.count % 18
        }
    }

    func initCollectionView() {
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        let cellWidth = (width-21)/3
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = cellSize
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.registerClass(PhotoAlbumCellCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(self.view).inset(4)
            make.bottom.equalTo(self.view).offset(0)
            make.centerX.equalTo(self.view)
            make.height.equalTo(height * 0.6)
        }

    }
    
    func createButton() -> UIButton {
        let button = UIButton()
        button.setTitle("New Collection", forState: .Normal)
        let color = UIColor(red: 0.35, green: 0.25, blue: 0.75, alpha: 1)
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
    
    func getFlickrPhotos(pageNum: Int) {
        
        FlickrAPI.sharedInstance().getPicturesFromPin(pin, pageNum: pageNum) { (result, error) -> Void in
            if let error = error {
                print("Getting pictures from pin, \(error)")
            } else {
                print("success^^^^^^^^^^^^^^^^^^^^^")
                if result!.isEmpty {
                    //No photo found in this label display label
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.displayNoPicLabel()
                    })
                } else {
                    
                    
                    // Parse the array of movies dictionaries
                    let _ = result!.map() { (dictionary: [String : String]) -> Photo in
                        
                        let photo = Photo(imageUrlStr: dictionary["url_q"]!, insertIntoManagedObjectContext: self.sharedContext)
                        photo.pin = self.pin
                        return photo
                        
                    }
                    // Update the table on the main thread
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.collectionView.reloadData()
                    })
                    self.saveContext()
                }
            }
        }
    }
    
    func displayNoPicLabel() {
        let label = UILabel(frame: CGRectZero)
        self.view.addSubview(label)
        label.text = "No Images"
        label.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(view)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
    }
    

    // MARK: - UICollectionView delegate and datasource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
        //Maybe change to return max 18 items, but can't make it work compatible with coredata's indexes
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoAlbumCellCollectionViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Hightlight the cell, enable the delete button at bottom of view, toggle the edit flag?
        print("selected a cell : \(indexPath.item)")
        if selectedIndexes.count == 0 {
            self.enableDeleteButton()
        }
        selectedIndexes.append(indexPath)
        print(indexPath.description)
        self.enableDeleteButton()
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCellCollectionViewCell
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            cell.imageView.alpha = 0.6
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        // De-hightlight the cell, disable the delete button
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCellCollectionViewCell
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            cell.imageView.alpha = 1
        }
        print("Deselected a cell : \(indexPath.item)")
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
        }
        if selectedIndexes.count == 0 {
            self.deleteEnabled = false
            self.newOrDeleteButton.setTitle("New Collection", forState: .Normal)
            self.newOrDeleteButton.backgroundColor = UIColor.grayColor()
        }
    }
    
    
    // MARK: - Helper function to configure cell
    func configureCell(cell: PhotoAlbumCellCollectionViewCell, indexPath: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        var image = UIImage(named: "imgPlaceHolder")
        
        if photo.imgUrl == nil {
            cell.imageView.image = image

        } else if photo.image != nil {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView!.image = photo.image!
            })
        }
            
        else { // A case where Photo object has an image name, but it is not downloaded yet.
            
            let task = FlickrAPI.sharedInstance().imgFromURL(photo.imgUrl!, completionHandler: { (imageData, error) -> Void in
                if let error = error {
                    print(error.debugDescription)
                }
                if let data = imageData {
                    image = UIImage(data: data)
                    photo.image = image
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.imageView!.image = image
                    })
                }
            })
            
            cell.taskToCancelifCellIsReused = task
        }
//        if !self.selectedIndexes.contains(indexPath) {
//            cell.imageView.alpha = 1
//        }
    }
    
    // action handler
    func enableDeleteButton() {
        deleteEnabled = true
        newOrDeleteButton.setTitle("Delete", forState: .Normal)
        newOrDeleteButton.backgroundColor = UIColor.redColor()
    }
    
    func buttonAction(sender: UIButton) {
        if deleteEnabled {
            // perform delete function
            var photosToDelete = [Photo]()
            for indexPath in self.selectedIndexes {
                photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
            }
            for photo in photosToDelete {
                sharedContext.deleteObject(photo)
            }
            self.saveContext()
            selectedIndexes = [NSIndexPath]()
            deleteEnabled = false
            self.newOrDeleteButton.setTitle("New Collection", forState: .Normal)
            self.newOrDeleteButton.backgroundColor = UIColor.grayColor()
            
        } else {
            // load new collection mode is on, perform load new photos action
            self.pageNumber = pageNumber! + 1
            self.getFlickrPhotos(pageNumber!)
        }
    }
    
    // MARK: - Core Data properties
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let request = NSFetchRequest(entityName: "Photo")
        
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "pin == %@", self.pin)
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return controller
    }()
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    private func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
}


extension PhotoAlbumVC: NSFetchedResultsControllerDelegate {
    
    // MARK: - Core Data properties
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        print("controller did change content")
        
        collectionView.performBatchUpdates({() -> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }

    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            
        case .Update:
            updatedIndexPaths.append(indexPath!)
            
        default:
            return
        }
    }
    
    
    
}






