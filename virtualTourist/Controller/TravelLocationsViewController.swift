//
//  TravelLocationsViewController.swift
//  virtualTourist
//
//  Created by Colin Walsh on 3/8/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var deleteToolbar: UIToolbar!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(mapTapped))
        gesture.delegate = self
        mapView.addGestureRecognizer(gesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !deleteToolbar.isHidden {
            deleteToolbar.isHidden = true
            deleteLabel.isHidden = true
            showHideToolbar()
        }
    }
    
    func showHideToolbar() {
        if deleteToolbar.isHidden {
            mapView.frame.size.height += deleteToolbar.frame.height
            deleteToolbar.frame.origin.y += deleteToolbar.frame.height
        } else {
            mapView.frame.size.height -= deleteToolbar.frame.height
            deleteToolbar.frame.origin.y -= deleteToolbar.frame.height
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        guard let coordinate = sender as? CLLocationCoordinate2D else {return}
        let destination = segue.destination as! PhotoAlbumViewController
        destination.location = coordinate
        FlickrAPIClient.makeRequestWith(lat: Double(coordinate.latitude), long: Double(coordinate.longitude), completion: {photoObj in
            print(photoObj)
            destination.photosInit = photoObj
        })
        backItem.title = "OK"
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func editTapped(_ sender: Any) {
        deleteToolbar.isHidden = !deleteToolbar.isHidden
        deleteLabel.isHidden = !deleteLabel.isHidden
        showHideToolbar()
    }
    
    
    @objc func mapTapped(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: mapView)
        let coord = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        mapView.addAnnotation(annotation)
    }
}

extension TravelLocationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if deleteToolbar.isHidden {
            performSegue(withIdentifier: "toAlbum", sender: view.annotation?.coordinate)
        } else {
            mapView.removeAnnotation(view.annotation!)
        }
    }
    
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
