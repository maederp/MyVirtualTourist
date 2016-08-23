//
//  TravelLocationsMapViewController.swift
//  My Virtual Tourist
//
//  Created by Peter Mäder on 21.07.16.
//  Copyright © 2016 Peter Mäder. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Default constant dictionairy keys to safe/restore map region
    struct DefaultsConstants {
        static let longitude = "longitude"      // Double
        static let latitude = "latitude"        // Double
        static let spanLongitude = "spanLongitude"  //Double
        static let spanLatitude = "spanLatitude"    //Double
    }
    
    // MARK: Properties
    @IBOutlet weak var travelLocationsMapView: MKMapView!
    
    // User Defaults persistence
    let UserDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    // Context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        travelLocationsMapView.delegate = self
        
        // MARK: Add LongPressGestureRecognizer
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.respondToLongPressGesture))
        longPressGestureRecognizer.minimumPressDuration = CFTimeInterval(0.8)
        
        travelLocationsMapView.addGestureRecognizer(longPressGestureRecognizer)
        
        
        // MARK: fetch CoreData
        do{
            try fetchedResultsController.performFetch()
        }catch{
            print(error)
        }
        
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar in TravelLocation Map View
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // TODO: Put Region setting into own Method
        // Retrieve User Defaults
        let latitude = UserDefaults.doubleForKey(DefaultsConstants.latitude)
        let longitude = UserDefaults.doubleForKey(DefaultsConstants.longitude)
        let spanLatitude = UserDefaults.doubleForKey(DefaultsConstants.spanLatitude)
        let spanLongitude = UserDefaults.doubleForKey(DefaultsConstants.spanLongitude)
        
        var currentRegion : MKCoordinateRegion = MKCoordinateRegion()
        
        if (latitude != 0 && longitude != 0) {
            // MARK: set region for Map to UserDefault
            let center : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpan(latitudeDelta: spanLatitude, longitudeDelta: spanLongitude)
            currentRegion = MKCoordinateRegion(center: center , span: span)
        } else{
            // MARK: set region for Map to Default: Bern Bundesplatz Switzerland
            let center : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 46.9470, longitude: 7.4439)
            let span = MKCoordinateSpan(latitudeDelta: 6.0, longitudeDelta: 6.0)
            currentRegion = MKCoordinateRegion(center: center , span: span)
        }
        
        travelLocationsMapView.setRegion(currentRegion, animated: true)
    }
    
    
    // MARK: MapViewDelegate Section
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // Center
        UserDefaults.setDouble(mapView.region.center.longitude, forKey: DefaultsConstants.longitude)
        UserDefaults.setDouble(mapView.region.center.latitude, forKey: DefaultsConstants.latitude)
        
        // SPAN
        let span = mapView.region.span
        let spanLat = Double(span.latitudeDelta)
        let spanLon = Double(span.longitudeDelta)
        
        UserDefaults.setDouble(spanLon, forKey: DefaultsConstants.spanLongitude)
        UserDefaults.setDouble(spanLat, forKey: DefaultsConstants.spanLatitude)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let customPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "locationPinView")
        
        customPinView.pinTintColor = MKPinAnnotationView.redPinColor()
        customPinView.animatesDrop = true
        customPinView.canShowCallout = true
        
        let rightButton = UIButton(type: .DetailDisclosure)
        rightButton.addTarget(nil, action: nil, forControlEvents: .TouchUpInside)
        customPinView.rightCalloutAccessoryView = rightButton
        
        return customPinView
    }
    
    // Load Pins once Map is fully loaded
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        travelLocationsMapView.addAnnotations((fetchedResultsController.fetchedObjects as! [Pin]))
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        
        // MARK: Find the Pin to represented by this tapped Annotation
        let annotation = view.annotation
        
        let pins = fetchedResultsController.fetchedObjects as! [Pin]
        
        for pin in pins{
            if (pin.coordinate.latitude == annotation?.coordinate.latitude &&
            pin.coordinate.longitude == annotation?.coordinate.longitude) {
                controller.pin = pin
            }
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    // MARK: CoreData Section
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
          
            let newPin = controller.objectAtIndexPath(newIndexPath!) as! Pin
            newPin.showOnMapView(self.travelLocationsMapView)

            FlickrClient.sharedInstance().getFotoListByGeoLocation(newPin){ (success, error) in
                
                if error == nil{
                    print("Fotos loaded into CoreData")
                }else{
                    print ("Error: \(error?.domain)")
                }
            }
            
        case .Delete:
            print("at .Delete Object")
        case .Update:
            print("at .Update Object")
        default:
            print("ran into default")
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
    }
    
    func addPinToStack(location: CLLocationCoordinate2D){
        
        let date_local = NSDate()
        
        let dictionary: [String:AnyObject] = [
            Pin.Keys.Latitude : location.latitude,
            Pin.Keys.Longitude : location.longitude,
            Pin.Keys.Timestamp : date_local
        ]
        
        let _ = Pin(dictionary: dictionary, context: self.sharedContext)
        
        CoreDataStackManager.sharedInstance().saveContext()
    }
        
    
    // MARK: Gesture Recognizer Section
    func respondToLongPressGesture(recognizer: UILongPressGestureRecognizer){
        
        // catch only 1 single gesture so limit to state = Ended
        if (recognizer.state == UIGestureRecognizerState.Ended){
            let location = recognizer.locationInView(self.travelLocationsMapView)
            let coordinates = travelLocationsMapView.convertPoint(location, toCoordinateFromView: self.travelLocationsMapView)
            
            addPinToStack(coordinates)
        }
        
    }
}