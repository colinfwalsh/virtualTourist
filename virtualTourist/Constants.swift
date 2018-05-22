//
//  Constants.swift
//  virtualTourist
//
//  Created by Colin Walsh on 3/15/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import Foundation

struct Constants {
    
    let apiKey = "d99574b2fea1a5693004481c53f4e21f"
    
    private func constructUrlString(lat: Double, long: Double, page: Int) -> String {
        return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(lat)&lon=\(long)&format=json&nojsoncallback=1&extras=url_m&per_page=21&page=\(page)"
    }
    
    func createUrl(lat: Double, long: Double, page: Int) -> URL? {
        return URL(string: constructUrlString(lat: lat, long: long, page: page))
    }
    
}
