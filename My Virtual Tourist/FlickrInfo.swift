//
//  FlickrInfo.swift
//  My Virtual Tourist
//
//  Created by Peter Mäder on 25.08.16.
//  Copyright © 2016 Peter Mäder. All rights reserved.
//

import Foundation
import CoreData


class FlickrInfo: NSManagedObject {

    struct Keys {
        static let Pin = "pin"
        static let LastUsedPage = "page"
        static let MaxPages = "pages"
        static let TotalImages = "total"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject?], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("FlickrInfo", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        lastUsedPage = dictionary[Keys.LastUsedPage] as? Int
        maxPages = dictionary[Keys.MaxPages] as? Int
        totalImages = dictionary[Keys.TotalImages] as? String
        pin = dictionary[Keys.Pin] as? Pin
    }
}
