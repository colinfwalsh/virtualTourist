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

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(mapTapped))
        gesture.delegate = self
        mapView.addGestureRecognizer(gesture)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "OK"
        navigationItem.backBarButtonItem = backItem
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
        print("Selected")
        performSegue(withIdentifier: "toAlbum", sender: view)
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
