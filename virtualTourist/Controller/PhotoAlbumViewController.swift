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
    
    var pin: Pin!
    
    var dataController: DataController!
    
    var deleteIndexes: [Int] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.delegate = self
        
        if (self.pin.photos?.array.isEmpty)! {
            FlickrAPIClient.makeRequestWith(lat: self.pin.latitude, long: self.pin.longitude, completion: {[weak self] photoObj in
                
                guard let `self` = self else {return}
                
                let photoArray: [Photo] = photoObj.photos.photo.map { item in
                    let photoCD = Photo(context: self.dataController.viewContext)
                    let photoData = try? Data(contentsOf: item.url_m)
                    if let image = UIImage(data: photoData!) {
                        photoCD.photoBinary = UIImageJPEGRepresentation(image, 1)
                        return photoCD
                    } else {
                        return Photo()
                    }
                }
                
                DispatchQueue.main.async {
                    let orderedSet = NSOrderedSet(array: photoArray)
                    self.pin.addToPhotos(orderedSet)
                    try? self.dataController.viewContext.save()
                    self.collectionView.reloadData()
                }
            })
        }
        
        setAnnotationAndRegion()
        disableInteraction()
    }
    
    func setAnnotationAndRegion() {
        let annotation = MKPointAnnotation()
        let locationAsC2D = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotation.coordinate = locationAsC2D
        mapView.addAnnotation(annotation)
        mapView.setCenter(locationAsC2D, animated: true)
        let region = MKCoordinateRegionMakeWithDistance(locationAsC2D, 1000, 1000)
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
            FlickrAPIClient.makeRequestWith(lat: Double(pin.latitude), long: Double(pin.longitude), completion: {photoObj in
                DispatchQueue.main.async {
                    self.toolBarButton.isEnabled = true
                }
            })
        } else {
            toolBarButton.title = "New Collection"
            for i in deleteIndexes {
                //                deleteItems(i)
            }
            self.deleteIndexes.removeAll()
        }
    }
    
    func deleteItems(_ i: Int) {
        //Do this once coreData is up and running
        collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: [IndexPath(item: i, section: 0)])
        }, completion: { (bool) in
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)        })
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photosCount = pin.photos?.count {
            return photosCount == 0 ? 21 : photosCount
        } else {
            return 21
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
        
        guard let photos = pin.photos else {return self.initLoadingCell(indexPath: indexPath)}
        
        if photos.count == 0 {
            return self.initLoadingCell(indexPath: indexPath)
        }
        
        guard let photoCD = photos.object(at: indexPath.row) as? Photo else {
            return self.initLoadingCell(indexPath: indexPath)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        
        DispatchQueue.main.async {
            cell.imageView.contentMode = .scaleToFill
            cell.imageView.image = UIImage(data: photoCD.photoBinary!)
        }
        
        return cell
    }
    
    func initLoadingCell(indexPath: IndexPath) -> LoadingCollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCell", for: indexPath) as! LoadingCollectionViewCell
        cell.activityIndicatorView.startAnimating()
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
