//
//  PhotoAlbumViewController.swift
//  My Virtual Tourist
//
//  Created by Peter Mäder on 28.07.16.
//  Copyright © 2016 Peter Mäder. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UICollectionViewDelegate {
    
    // MARK: Properties
    
    var pin : Pin!
    
    @IBOutlet weak var pinLocationMapView: MKMapView!
    
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    
    
    // Context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    // MARK: UI Lifecycle Section
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: fetch CoreData
        do{
            try fetchedResultsController.performFetch()
        }catch{
            print(error)
        }
        
        fetchedResultsController.delegate = self
        photoAlbumCollectionView.delegate = self
        
        photoAlbumCollectionView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make Navigation Bar visible
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Create Return/Done Navigation Button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(PhotoAlbumViewController.dismissViewController) )
        
        // Create Add/Reload Navigation Button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .Done, target: self, action: #selector(PhotoAlbumViewController.loadNewSetOfPhotos))
        
        let center : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: pin.latitude!.doubleValue, longitude: pin.longitude!.doubleValue)
        let span = MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
        let currentRegion = MKCoordinateRegion(center: center, span: span)
        
        pinLocationMapView.setRegion(currentRegion, animated: true)
        pinLocationMapView.scrollEnabled = false
        
        pin.showOnMapView(self.pinLocationMapView)
        
        if pin.photos?.count == 0 {
            FlickrClient.sharedInstance().getFotoListByGeoLocation(pin){ (success, error) in
                if error == nil{
                    print("Fotos loaded into CoreData")
                }else{
                    print ("Error: \(error?.domain)")
                }
            }
        }
    }
    
    
    // MARK: CoreData Section
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    

    // MARK: MapView Section
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let customPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "locationPinView")
        
        customPinView.pinTintColor = MKPinAnnotationView.redPinColor()
        customPinView.animatesDrop = true
        customPinView.canShowCallout = false
        
        return customPinView
    }
    
    
    // MARK: CollectionView Section
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = pin.photos?.objectAtIndex(indexPath.item) as? Photo
        
        let cellIdentifier = "FlickrImageCollectionsViewCell"
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! FlickrImageCollectionsViewCell
        
        dispatch_async(dispatch_get_main_queue()) {
            cell.imageView.image = UIImage(imageLiteral: "FotoPlaceholder")
        }
        
        if let imageData = photo?.image {
            dispatch_async(dispatch_get_main_queue()) {
                cell.imageView.image = UIImage(data: imageData)
            }
        } 
        
        return cell
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let photos = pin.photos?.mutableCopy() as! NSMutableOrderedSet
        
        photos.removeObjectAtIndex(indexPath.item)
        
        pin.replaceFotos(photos)
        CoreDataStackManager.sharedInstance().saveContext()
        
        // MARK: fetch CoreData
        do{
            try fetchedResultsController.performFetch()
        }catch{
            print(error)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.photoAlbumCollectionView.reloadData()
        }
    }
    
    
    // MARK: Utilities
    func dismissViewController() -> Void {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func loadNewSetOfPhotos() -> Void {
        
        let actionSheet = UIAlertController(title: "Do you like to reload new Photos ?", message: nil, preferredStyle: .ActionSheet)

        let reloadAction = UIAlertAction(title: "Yes, please reload", style: .Default, handler: reloadHandler)
        
        let cancelAction = UIAlertAction(title: "No, keep photos", style: .Cancel, handler: nil)
        
        actionSheet.addAction(reloadAction)
        actionSheet.addAction(cancelAction)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    func reloadHandler(action: UIAlertAction!){
        
        // delete all photos for this pin
        let photos = pin.photos?.mutableCopy() as! NSMutableOrderedSet
        photos.removeAllObjects()
        pin.replaceFotos(photos)
        
        CoreDataStackManager.sharedInstance().saveContext()
        
        FlickrClient.sharedInstance().getFotoListByGeoLocation(pin){ (success, error) in
            if error == nil{
                print("Fotos loaded into CoreData")
                
                // MARK: fetch CoreData
                do{
                    try self.fetchedResultsController.performFetch()
                    dispatch_async(dispatch_get_main_queue()) {
                        self.photoAlbumCollectionView.reloadData()
                    }
                }catch{
                    print(error)
                }
                
            }else{
                print ("Error: \(error?.domain)")
            }
        }
        
        
    }
}
