//
//  PhotoAlbumViewController.swift
//  virtualTourist
//
//  Created by Colin Walsh on 3/8/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PhotoAlbumViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolBarButton: UIBarButtonItem!
    
    var location: CLLocationCoordinate2D!
    
    var photosInit: [String: Any] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.delegate = self
        
    }
 }

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let photoDict: [String:Any] = photosInit["photos"] as! [String : Any]
        let photoArray: [[String:Any]] = photoDict["photo"]! as! [[String:Any]]
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        let photoDict: [String:Any] = photosInit["photos"] as! [String : Any]
        let photoArray: [[String:Any]] = photoDict["photo"]! as! [[String:Any]]
        guard let urlString = photoArray[indexPath.row]["url_m"] as? String else {return UICollectionViewCell()}
        guard let url = URL(string: urlString) else {return UICollectionViewCell()}
        guard let imageData = try? Data(contentsOf: url) else {return UICollectionViewCell()}
        
        DispatchQueue.main.async {
            cell.imageView.image = UIImage(data: imageData)
        }
        return cell
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width/3.25, height: self.collectionView.frame.height/4.25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
 
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 7.5, bottom: 5, right: 7.5)
    }
 
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    
}
