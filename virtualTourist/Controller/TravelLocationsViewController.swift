//
//  TravelLocationsViewController.swift
//  virtualTourist
//
//  Created by Colin Walsh on 3/8/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var deleteToolbar: UIToolbar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var pins: [Pin] = []
    
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(mapTapped))
        mapView.addGestureRecognizer(gesture)
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        guard let result = try? dataController.viewContext.fetch(fetchRequest) else {return}
        
        pins = result
        
        addSavedPinsToMap()
    }
    
    func addSavedPinsToMap() {
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadingIndicator.isHidden = true
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
            editButton.title = "Edit"
        } else {
            mapView.frame.size.height -= deleteToolbar.frame.height
            deleteToolbar.frame.origin.y -= deleteToolbar.frame.height
            editButton.title = "Done"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        guard let pin = sender as? Pin else {return}
        let destination = segue.destination as! PhotoAlbumViewController
        destination.pin = pin
        backItem.title = "OK"
        destination.dataController = self.dataController
        navigationItem.backBarButtonItem = backItem
        
    }
    
    @IBAction func editTapped(_ sender: Any) {
        deleteToolbar.isHidden = !deleteToolbar.isHidden
        deleteLabel.isHidden = !deleteLabel.isHidden
        showHideToolbar()
    }
    
    @objc func mapTapped(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: mapView)
            let coord = mapView.convert(location, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            mapView.addAnnotation(annotation)
            let newPin = Pin(context: dataController.viewContext)
            newPin.latitude = Double(coord.latitude)
            newPin.longitude = Double(coord.longitude)
            pins.insert(newPin, at: 0)
            try? dataController.viewContext.save()
            return
        }
    }
}

extension TravelLocationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        let pinSelected = pins.filter { (pin) -> Bool in
            return (pin.latitude == view.annotation?.coordinate.latitude) && (pin.longitude == view.annotation?.coordinate.longitude)
        }
        if deleteToolbar.isHidden {
            let pinToSend = pinSelected[0]
            self.loadingIndicator.stopAnimating()
            self.performSegue(withIdentifier: "toAlbum", sender: pinToSend)
        } else {
            mapView.removeAnnotation(view.annotation!)
            let index = pins.index(of: pinSelected[0])
            dataController.viewContext.delete(pinSelected[0])
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.isHidden = true
            try? self.dataController.viewContext.save()
            pins.remove(at: index!)
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
