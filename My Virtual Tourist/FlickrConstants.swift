//
//  FlickrConstants.swift
//  My Virtual Tourist
//
//  Created by Peter Mäder on 27.07.16.
//  Copyright © 2016 Peter Mäder. All rights reserved.
//

extension FlickrClient{
    
    struct APIConstants {
        static let ApiKey = "eb3505a91675db223755acd8a2d68e79"
        static let ApiSecret = "fadb32fb92666c29"
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
    }
    
    struct Methods {
        static let FlickrPhotoSearch = "flickr.photos.search"
        static let FlickrPhotosGetSizes = "flickr.photos.getSizes"
    }
    
    // MARK: Flickr Photo Search Constants
    struct ConstantsFlickrPhotoSearch {
        static let ApiKey = "api_key"
        static let Method = "method"
        static let Lat = "lat"
        static let Lon = "lon"
        static let Radius = "radius"
        static let Per_page = "per_page"
        static let Page = "page"
        static let Format = "format"
        static let NoJSONCallBack = "nojsoncallback"
    }
    
    struct ConstantsFlickrPhotoSearchResponse {
        static let Photos = "photos"
        static let Photo = "photo"
        static let id = "id"
        static let owner = "owner"
        static let source = "source"
        static let title = "title"
    }
    
    // MARK: Flickr GetSizes Constants
    struct ConstantsFlickrGetSizes {
        static let PhotoID = "photo_id"
    }
    
    struct ConstantsFlickrGetSizesResponse {
        static let Sizes = "sizes"
        static let Size = "size"
        static let Label = "label"
        static let Width = "width"
        static let Height = "height"
        static let Source = "source"
        static let Url = "url"
        static let Media = "media"
    }
}
