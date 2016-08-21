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
    func getFotoListByGeoLocation(locationPin: Pin, completionHandler: CompletionHandler) {
        
        // TODO: find a way to retrieve current map span
        let parameters : [String:AnyObject] = [
            FlickrClient.ConstantsFlickrPhotoSearch.Lat : locationPin.latitude!.doubleValue,
            FlickrClient.ConstantsFlickrPhotoSearch.Lon : locationPin.longitude!.doubleValue,
            FlickrClient.ConstantsFlickrPhotoSearch.Radius : 5,
            FlickrClient.ConstantsFlickrPhotoSearch.Format : "json",
            FlickrClient.ConstantsFlickrPhotoSearch.NoJSONCallBack : 1,
            FlickrClient.ConstantsFlickrPhotoSearch.Per_page : 12
        ]
        
        taskForGETMethod(FlickrClient.Methods.FlickrPhotoSearch, parameters: parameters) { (results, error) in
            
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                
                if let photos = results[FlickrClient.ConstantsFlickrPhotoSearchResponse.Photos] as? [String:AnyObject] {
                    
                    if let photoArray = photos[FlickrClient.ConstantsFlickrPhotoSearchResponse.Photo] as? [[String:AnyObject]]{
                        
                        for photo in photoArray{
                            
                            self.getFotoForId((photo[FlickrClient.ConstantsFlickrPhotoSearchResponse.id] as! String)){ (image, error) in
                                
                                if image != nil{
                                    
                                    let addFotoDict : [String:AnyObject?] = [
                                        Photo.Keys.ID : photo[FlickrClient.ConstantsFlickrPhotoSearchResponse.id],
                                        Photo.Keys.Owner : photo[FlickrClient.ConstantsFlickrPhotoSearchResponse.owner],
                                        Photo.Keys.Pin : locationPin,
                                        Photo.Keys.Source : photo[FlickrClient.ConstantsFlickrPhotoSearchResponse.source],
                                        Photo.Keys.Title : photo[FlickrClient.ConstantsFlickrPhotoSearchResponse.title],
                                        Photo.Keys.Image : (image as! NSData)
                                    ]
                                    
                                    let _ = Photo(dictionary: addFotoDict, context: self.sharedContext)
                                }else{
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
                            }
                        }
                        CoreDataStackManager.sharedInstance().saveContext()
                        completionHandler(result: true, error: nil)
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
                                print("hier bin ich \(url)")
                                
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
