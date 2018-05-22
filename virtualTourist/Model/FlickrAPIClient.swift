//
//  FlickrAPIClient.swift
//  virtualTourist
//
//  Created by Colin Walsh on 3/15/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import Foundation

struct FlickrAPIClient {
    static func makeRequestWith(lat: Double, long: Double, page: Int, completion: @escaping ((PhotosModel) -> Void)) {
        guard let url = Constants().createUrl(lat: lat, long: long, page: page) else {return}
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) {(data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let data = data {
                guard let photoObj = try? JSONDecoder().decode(PhotosModel.self, from: data) else {
                    fatalError("There was an error parsing the model, maybe the internet is down?")}
                completion(photoObj)
            }
        }
        task.resume()
    }
}
