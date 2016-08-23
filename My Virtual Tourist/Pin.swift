//
//  Pin.swift
//  My Virtual Tourist
//
//  Created by Peter Mäder on 27.07.16.
//  Copyright © 2016 Peter Mäder. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject, MKAnnotation {

    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Timestamp = "timestamp"
        static let Fotos = "fotos"
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
        timestamp = dictionary[Keys.Timestamp] as? NSDate
    }
    
    // MARK: MKAnnotation Protocol requirements
    var title: String? {
        return timestamp?.description ?? "New Pin"
    }
    
    var coordinate: CLLocationCoordinate2D {
        let coordinate = CLLocationCoordinate2D(latitude: latitude!.doubleValue, longitude: longitude!.doubleValue)
        return coordinate
    }
    
    func showOnMapView(view: MKMapView){
    
        let annotation = MKPointAnnotation()
    
        annotation.coordinate = self.coordinate
        annotation.title = self.timestamp?.description ?? "New Pin"
        
        view.addAnnotation(annotation)
        view.viewForAnnotation(annotation)
    }

}
