//
//  Photo+CoreDataProperties.swift
//  My Virtual Tourist
//
//  Created by Peter Mäder on 27.07.16.
//  Copyright © 2016 Peter Mäder. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var source: String?
    @NSManaged var owner: String?
    @NSManaged var image: NSData?
    @NSManaged var id: String?
    @NSManaged var title: String?
    @NSManaged var pin: Pin?

}
