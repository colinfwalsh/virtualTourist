//
//  TempModel.swift
//  virtualTourist
//
//  Created by Colin Walsh on 3/16/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import Foundation

struct PhotosModel: Codable {
    
    struct PhotosObject: Codable {
        let page: Int
        let pages: Int
        let perpage: Int
        let total: String
        
        struct Photo: Codable {
            let id: String
            let owner: String
            let secret: String
            let server: String
            let farm: Int
            let title: String
            let ispublic: Int
            let isfriend: Int
            let isfamily: Int
            let url_m: URL
            let height_m: String
            let width_m: String
        }
        
        var photo: [Photo]
    }
    
    var photos: PhotosObject
}


