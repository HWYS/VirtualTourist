//
//  FlickrApiClient.swift
//  Virtual Tourist
//
//  Created by Htet Wai Yan Swe on 1/9/22.
//

import Foundation

class FlickrApiClient {
    struct Constants {
        static let API_KEY = "a6356c4c9026a72841c9f6be92dcc29c"
        //a7820814cb815f5f
        static let BASE_URL_PLUS_API_KEY = "https://api.flickr.com/services/rest"
        static let FLICKR_API_METHOD = "flickr.photos.search"
        static let PHOTOS_PER_PAGE = 20
        static let PAGE_NO = Int.random(in: 1 ... 20)
        static let ACCURACY = 11
    }
}
