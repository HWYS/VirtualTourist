//
//  FlickrResponse.swift
//  Virtual Tourist
//
//  Created by Htet Wai Yan Swe on 1/13/22.
//

import Foundation

struct FlickerResponse: Codable{
    
    let photos: MainResponse
}

struct MainResponse: Codable {
    let photo: [Photo]
}

struct Photo: Codable {
    let id: String
    let secret: String
    let serverId: String
    let farmNumber: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case secret = "secret"
        case serverId = "server"
        case farmNumber = "farm"
    }
}
