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
    
    var photosInit: PhotosModel? {
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
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
        mapView.setCenter(location, animated: true)
        let region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000)
        mapView.setRegion(region, animated: true)
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
    }
    
    @IBAction func toolButtonTapped(_ sender: Any) {
        toolBarButton.isEnabled = false
        FlickrAPIClient.makeRequestWith(lat: Double(location.latitude), long: Double(location.longitude), completion: {photoObj in
            DispatchQueue.main.async {
                self.photosInit = photoObj
                self.toolBarButton.isEnabled = true
            }
        })
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photosInit = photosInit {
            return photosInit.photos.photo.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        guard let url = photosInit?.photos.photo[indexPath.row].url_m else {return UICollectionViewCell()}
        guard let imageData = try? Data(contentsOf: url) else {return UICollectionViewCell()}
        
        DispatchQueue.main.async {
            cell.imageView.contentMode = .scaleToFill
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
