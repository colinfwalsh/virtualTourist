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
    
    var deleteIndexes: [Int] = []
    
    var photosInit: PhotosModel! {
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
        
        
        setAnnotationAndRegion()
        disableInteraction()
    }
    
    func setAnnotationAndRegion() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
        mapView.setCenter(location, animated: true)
        let region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000)
        mapView.setRegion(region, animated: true)
    }
    
    func disableInteraction() {
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
    }
    
    @IBAction func toolButtonTapped(_ sender: Any) {
        
        if toolBarButton.title == "New Collection" {
            toolBarButton.isEnabled = false
            FlickrAPIClient.makeRequestWith(lat: Double(location.latitude), long: Double(location.longitude), completion: {photoObj in
                DispatchQueue.main.async {
                    self.photosInit = photoObj
                    self.toolBarButton.isEnabled = true
                }
            })
        } else {
            toolBarButton.title = "New Collection"
            for i in deleteIndexes {
                self.photosInit.photos.photo.remove(at: i)
//                deleteItems(i)
            }
            self.deleteIndexes.removeAll()
        }
    }
    
    func deleteItems(_ i: Int) {
        //Do this once coreData is up and running
        collectionView.performBatchUpdates({
            self.photosInit.photos.photo.remove(at: i)
            self.collectionView.deleteItems(at: [IndexPath(item: i, section: 0)])
        }, completion: { (bool) in
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)        })
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photosInit = photosInit {
            return photosInit.photos.photo.count
        } else {
            return 20
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Needs work, needs to be done with CoreData implementation
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumCollectionViewCell
        toolBarButton.title = "Remove Selected Pictures"
        deleteIndexes.append(indexPath.row)
//        if cell.imageView.alpha == 1.0 {
//            cell.backgroundColor = .white
//            cell.imageView.alpha = 0.5
//            deleteIndexes.append(indexPath.row)
//        } else {
//            cell.backgroundColor = .gray
//            cell.imageView.alpha = 1.0
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let url = photosInit?.photos.photo[indexPath.row].url_m else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCell", for: indexPath) as! LoadingCollectionViewCell
            cell.activityIndicatorView.startAnimating()
            return cell}
        guard let imageData = try? Data(contentsOf: url) else {
           return UICollectionViewCell()}
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
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
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
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
