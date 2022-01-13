//
//  FlickrApiClient.swift
//  Virtual Tourist
//
//  Created by Htet Wai Yan Swe on 1/9/22.
//

import Foundation
import CoreLocation

class FlickrApiClient {
    struct Constants {
        static let API_KEY = "a6356c4c9026a72841c9f6be92dcc29c"
        //a7820814cb815f5f
        static let BASE_URL = "https://api.flickr.com/services/rest"
        static let FLICKR_API_METHOD = "flickr.photos.search"
        static let PHOTOS_PER_PAGE = 20
        static let PAGE_NO = Int.random(in: 1 ... 20)
        static let ACCURACY = 11
        static let RESPONSE_FORMAT = "json"
    }
    
    class func getPhotos(lat: Double, long: Double) {
        let urlString = "\(Constants.BASE_URL)?api_key=\(Constants.API_KEY)&method=\(Constants.FLICKR_API_METHOD)&per_page=\(Constants.PHOTOS_PER_PAGE)&format=\(Constants.RESPONSE_FORMAT)&nojsoncallback=?&lat=\(lat)&lon=\(long)&page=\(Constants.PAGE_NO)"
        let url = URL(string: urlString)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            print(data)
        }
        task.resume()
    }
}
