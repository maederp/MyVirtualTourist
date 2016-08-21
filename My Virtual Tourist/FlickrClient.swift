//
//  FlickrClient.swift
//  My Virtual Tourist
//
//  Created by Peter Mäder on 27.07.16.
//  Copyright © 2016 Peter Mäder. All rights reserved.
//

import Foundation
import CoreData

class FlickrClient: NSObject {
    
    typealias CompletionHandler = (result: AnyObject!, error: NSError?) -> Void
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // Context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // MARK: - Task for GET Requests to Flickr, API Key automatically added
    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandlerForGET: CompletionHandler) -> NSURLSessionDataTask {
        
        /* Set the parameters and add API Key + FlickR query method */
        var parametersWithApiKey = parameters
        parametersWithApiKey[FlickrClient.ConstantsFlickrPhotoSearch.ApiKey] = FlickrClient.APIConstants.ApiKey
        parametersWithApiKey[FlickrClient.ConstantsFlickrPhotoSearch.Method] = method
        
        /* Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: URLFromParameters(parametersWithApiKey))
        print("URL: \(request.URL)")
        
        /* Create and execute the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx -> \(response)")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
    
    // MARK: Utilities
    
    // -> create a URL from parameters, fix Flikr API Host & Path
    private func URLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = FlickrClient.APIConstants.ApiScheme
        components.host = FlickrClient.APIConstants.ApiHost
        components.path = FlickrClient.APIConstants.ApiPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    // -> Parsing JSON Data
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: CompletionHandler) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
}