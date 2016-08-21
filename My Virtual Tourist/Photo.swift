//
//  Photo.swift
//  My Virtual Tourist
//
//  Created by Peter Mäder on 27.07.16.
//  Copyright © 2016 Peter Mäder. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

    struct Keys {
        static let Image = "image"
        static let Pin = "pin"
        static let ID = "id"
        static let Owner = "owner"
        static let Source = "source"
        static let Title = "title"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject?], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.ID] as? String
        owner = dictionary[Keys.Owner] as? String
        pin = dictionary[Keys.Pin] as? Pin
        image = dictionary[Keys.Image] as? NSData
        source = dictionary[Keys.Source] as? String
        title = dictionary[Keys.Title] as? String
    }

}
