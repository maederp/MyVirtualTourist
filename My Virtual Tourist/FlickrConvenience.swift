//
//  FlickrConvenience.swift
//  My Virtual Tourist
//
//  Created by Peter Mäder on 27.07.16.
//  Copyright © 2016 Peter Mäder. All rights reserved.
//
import Foundation

extension FlickrClient{
    
    // MARK: Get fotos by geo location
    func getFotoListByGeoLocation(locationPin: Pin, flickrInfo: FlickrInfo?, completionHandler: CompletionHandler) {
        
        //initialize Flickr Page to 1
        var flickrSearchPage = 1
        
        if flickrInfo != nil{
            var flickrMaxPage = flickrInfo?.maxPages as! Int
            
            //make sure search results only up to 4000 Pictures (333 Pages x 12 per Page)
            let maxPagesOfFlickrImageReturns = 333
            
            //FIX: avoid magic Numbers!
            flickrMaxPage = (flickrMaxPage < maxPagesOfFlickrImageReturns) ? flickrMaxPage : Int(arc4random_uniform(UInt32(333))+1)
            
            flickrSearchPage = Int(arc4random_uniform(UInt32(flickrMaxPage))+1)
        }
        
        // TODO: find a way to retrieve current map span
        let parameters : [String:AnyObject] = [
            FlickrClient.ConstantsFlickrPhotoSearch.Lat : locationPin.latitude!.doubleValue,
            FlickrClient.ConstantsFlickrPhotoSearch.Lon : locationPin.longitude!.doubleValue,
            FlickrClient.ConstantsFlickrPhotoSearch.Radius : 5,
            FlickrClient.ConstantsFlickrPhotoSearch.Format : "json",
            FlickrClient.ConstantsFlickrPhotoSearch.NoJSONCallBack : 1,
            FlickrClient.ConstantsFlickrPhotoSearch.Per_page : 12,
            FlickrClient.ConstantsFlickrPhotoSearch.Page : flickrSearchPage
        ]
        
        taskForGETMethod(FlickrClient.Methods.FlickrPhotoSearch, parameters: parameters) { (results, error) in
            
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                
                if let photos = results[FlickrClient.ConstantsFlickrPhotoSearchResponse.Photos] as? [String:AnyObject] {
                    
                    // CoreData access to happen in main queue !
                    dispatch_async(dispatch_get_main_queue()){
                        if flickrInfo != nil {
                            flickrInfo?.lastUsedPage = photos[ConstantsFlickrPhotoSearchResponse.Page] as! Int
                            CoreDataStackManager.sharedInstance().saveContext()
                        }else{
                            //Add FlickR search info relationship to Pin
                            let addFlickrInfo : [String:AnyObject?] = [
                                FlickrInfo.Keys.MaxPages : photos[ConstantsFlickrPhotoSearchResponse.Pages],
                                FlickrInfo.Keys.Pin : locationPin,
                                FlickrInfo.Keys.LastUsedPage : photos[ConstantsFlickrPhotoSearchResponse.Page],
                                FlickrInfo.Keys.TotalImages : photos[ConstantsFlickrPhotoSearchResponse.Total]
                            ]
                            
                            let _ = FlickrInfo(dictionary: addFlickrInfo, context: self.sharedContext)
                        }
                    }
                    

                    //Download & add Fotos
                    
                    if let photoArray = photos[FlickrClient.ConstantsFlickrPhotoSearchResponse.Photo] as? [[String:AnyObject]]{
                        
                        // CoreData access to happen in main queue !
                        dispatch_async(dispatch_get_main_queue()){
                            
                            for photo in photoArray{
                                
                                let addFotoDict : [String:AnyObject?] = [
                                    Photo.Keys.ID : photo[FlickrClient.ConstantsFlickrPhotoSearchResponse.id],
                                    Photo.Keys.Owner : photo[FlickrClient.ConstantsFlickrPhotoSearchResponse.owner],
                                    Photo.Keys.Pin : locationPin,
                                    Photo.Keys.Source : photo[FlickrClient.ConstantsFlickrPhotoSearchResponse.source],
                                    Photo.Keys.Title : photo[FlickrClient.ConstantsFlickrPhotoSearchResponse.title],
                                    Photo.Keys.Image : nil
                                ]
                                
                                let _ = Photo(dictionary: addFotoDict, context: self.sharedContext)
                            }
                            
                            CoreDataStackManager.sharedInstance().saveContext()
                            completionHandler(result: true, error: nil)
                        }
                    }
                } else {
                    completionHandler(result: false, error: NSError(domain: "getFotoListByGeoLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getFotoListByGeoLocation Json"]))
                }
            }
        }
    }
    
    func getFotoForId(photoID: String, completionHandler: CompletionHandler) {
        let parameters : [String:AnyObject] = [
            FlickrClient.ConstantsFlickrGetSizes.PhotoID : photoID,
            FlickrClient.ConstantsFlickrPhotoSearch.Format : "json",
            FlickrClient.ConstantsFlickrPhotoSearch.NoJSONCallBack : 1
        ]
        
        taskForGETMethod(FlickrClient.Methods.FlickrPhotosGetSizes, parameters: parameters) { (results, error) in
            
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                
                if let results = results[FlickrClient.ConstantsFlickrGetSizesResponse.Sizes] as? [String:AnyObject] {
                    
                    if let sizeArray = results[FlickrClient.ConstantsFlickrGetSizesResponse.Size] as? [[String:AnyObject]]{
                        
                        for size in sizeArray{
                            if size[FlickrClient.ConstantsFlickrGetSizesResponse.Label] as! String == "Square"{
                                let sourceUrlString = (size[FlickrClient.ConstantsFlickrGetSizesResponse.Source] as! String)
                                
                                let url = NSURL(string: sourceUrlString)
                                
                                let request = NSURLRequest(URL: url!)
                                
                                let task = self.session.dataTaskWithRequest(request) {(image, response, downloadError) in
                                    
                                    if let error = downloadError {
                                        completionHandler(result: nil, error: error)
                                    } else {
                                        completionHandler(result: image, error: nil)
                                    }
                                }
                                
                                task.resume()
                            }
                        }
                    }
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getFotoForId parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getFotoForId Json"]))
                }
            }
        }
    }
}
