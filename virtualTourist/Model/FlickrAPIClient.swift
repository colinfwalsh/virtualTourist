//
//  FlickrAPIClient.swift
//  virtualTourist
//
//  Created by Colin Walsh on 3/15/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import Foundation

struct FlickrAPIClient {
    static func makeRequestWith(lat: Double, long: Double, completion: @escaping ((PhotosModel) -> Void)) {
        guard let url = Constants().createUrl(lat: lat, long: long) else {return}
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) {(data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let data = data {
                guard let photoObj = try? JSONDecoder().decode(PhotosModel.self, from: data) else {
                    print("Error parsing!")
                    return}
//                guard let json = try?
//                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
//                    print("Error parsing data")
//                    return}
//                guard let jsonObj = json. else {
//                    print("Error casting for some reason")
//                    return}
                completion(photoObj)
            }
        }
        task.resume()
    }
}
