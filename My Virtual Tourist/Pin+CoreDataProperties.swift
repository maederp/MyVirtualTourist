//
//  Pin+CoreDataProperties.swift
//  My Virtual Tourist
//
//  Created by Peter Mäder on 26.08.16.
//  Copyright © 2016 Peter Mäder. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var timestamp: NSDate?
    @NSManaged var photos: NSOrderedSet?
    @NSManaged var flickrInfo: FlickrInfo?

}
