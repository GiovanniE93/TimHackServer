//
//  ViewController.swift
//  TimHackServer
//
//  Created by Giovanni Erpete on 03/07/2020.
//  Copyright © 2020 Giovanni Erpete. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var managerPisition : CLLocationManager!
    var userPosition : CLLocationCoordinate2D!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var titleTextField: UITextField!
    
    let coreDataController = CoreDataController.shared
    let apiManager = APIManager.getSingleton()
    
    override func viewWillAppear(_ animated: Bool) {
        coreDataController.fetchTotems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.myMapView.delegate = self
        self.managerPisition = CLLocationManager()
        self.managerPisition.delegate = self
        self.managerPisition.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.managerPisition.requestWhenInUseAuthorization()
        self.managerPisition.startUpdatingLocation()
        
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        self.userPosition = userLocation.coordinate
        print("[MapView - didUpdate]: posizione aggiornata: lat: \(self.userPosition.latitude) long: \(self.userPosition.longitude)")
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion (center: self.userPosition, span: span)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        print("[MapView - regionDidChane] lat: \(mapView.centerCoordinate.latitude) long: \(mapView.centerCoordinate.longitude)")
        
    }
    
    @IBAction func addAnnotation(_ sender: Any) {
        
        print("[AddAnnotation] title: \(self.titleTextField.text ?? "No Title")")
        
        let annotation = MKPointAnnotation()
        annotation.title = self.titleTextField.text
        annotation.coordinate = self.myMapView.centerCoordinate
        myMapView.addAnnotation(annotation)
        
        var city = ""
        geocode(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, completion: {placemarks, errors in
            print("[Geocode] \(placemarks?.first?.locality ?? "")")
            city = placemarks?.first?.locality ?? ""
        })
        
        self.apiManager.getData(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        self.coreDataController.addTotem(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, title: self.titleTextField.text ?? "", city: city)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.resignFirstResponder()
        
    }
    
    func geocode(latitude: Double, longitude: Double, completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemark, error in
            guard let placemark = placemark, error == nil else {
                completion(nil, error)
                return
            }
            completion(placemark, nil)
        }
    }
    
}

