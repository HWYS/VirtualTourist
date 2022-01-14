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
    
    enum Endpoints {
        case getPhotoIds(Double, Double)
        case downloadPhoto(String)
        
        var stringValue: String  {
            switch self {
            case .getPhotoIds(let lat, let lon):
                return Constants.BASE_URL + "?api_key=\(Constants.API_KEY)&method=\(Constants.FLICKR_API_METHOD)&per_page=\(Constants.PHOTOS_PER_PAGE)&format=\(Constants.RESPONSE_FORMAT)&nojsoncallback=1&lat=\(lat)&lon=\(lon)&page=\(Constants.PAGE_NO)&accuracy=\(Constants.ACCURACY)"
            case .downloadPhoto(let imageUrl):
                return imageUrl
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getPhotos(lat: Double, lon: Double, completion: @escaping ([Photo], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getPhotoIds(lat, lon).url, responseType: FlickerResponse.self) { response, error in
            if let response = response {
                completion(response.photos.photo, nil)
            }else {
                completion([], error)
            }
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        
        
    }
    
    class func downloadImage(imageUrl: String, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.downloadPhoto(imageUrl).url) { data, response, error in
            
            completion(data, error)
        }
        task.resume()
    }
}
