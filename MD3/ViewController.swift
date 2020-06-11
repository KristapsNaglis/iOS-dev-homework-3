//
//  ViewController.swift
//  MD3
//
//  Created by Students on 09/06/2020.
//  Copyright © 2020 KristapsNaglis. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
   
    @IBOutlet var mapView: MKMapView!
    
    private var locationManager:CLLocationManager?
    private var userLocationLat: Double = 0.0
    private var userLocationLon: Double = 0.0
//    private var destinationLat: Double = 57.535067
//    private var destinationLon: Double = 25.424228
    var ref: DatabaseReference!
    var locationNamesArray = [String]()
    var locationDescrArray = [String]()
    var locationCoordsArray = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        
        mapView.delegate = self
        
        ref = Database.database().reference()
        
        getUserLocation()
        
        readData();
    
    }
    
    func addPointOnMap(map: MKMapView, placeTitle: String, placeDescr: String, placeCoords: MKPointAnnotation){
        
        placeCoords.title = placeTitle
        placeCoords.subtitle = placeDescr
        
        map.addAnnotation(placeCoords)
    }
    
    // Reads coordinates and info from firebase
    func readData(){
        ref.child("locations").observe(.value) { snapshot in
            let locationsDict = snapshot.value as? [String: AnyObject] ?? [:]
            
            var name: String
            var descr: String
            var lat: Double
            var lon: Double
            
            for loop in locationsDict {
                
                name = loop.value.object(forKey: "name") as! String
                descr = loop.value.object(forKey: "description") as! String
                lat = loop.value.object(forKey: "lat") as! Double
                lon = loop.value.object(forKey: "lon") as! Double
                
                let coordinate = MKPointAnnotation()
                coordinate.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                self.locationNamesArray.append(name)
                self.locationDescrArray.append(descr)
                self.locationCoordsArray.append(coordinate)
                
            }
            
            let namesCount: Int = self.locationNamesArray.count
            let descrCount: Int = self.locationDescrArray.count
            let coordsCount: Int = self.locationCoordsArray.count
            
             // checks if all data has been loaded from firebase
            if namesCount == descrCount && descrCount == coordsCount {
                for loop in 0...namesCount-1 {
                    self.addPointOnMap(map: self.mapView, placeTitle: self.locationNamesArray[loop], placeDescr: self.locationDescrArray[loop], placeCoords: self.locationCoordsArray[loop])
                }
            }
        }
    }
    
    // Start location tracking
    func getUserLocation(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    // Delegate
    // Is called on every loccation update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let firstPoint = MKPointAnnotation()
        
        if let location = locations.last {
            userLocationLat = location.coordinate.latitude
            userLocationLon = location.coordinate.longitude
            
            firstPoint.coordinate = CLLocationCoordinate2D(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            firstPoint.title = "Your location"
            
            mapView.addAnnotation(firstPoint)
        }
    }
    
    func getRoute(_ coordinates: MKPointAnnotation){
        let request = MKDirections.Request()
        
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: userLocationLat, longitude: userLocationLon), addressDictionary: nil))
        
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates.coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
        guard let unwrappedResponse = response else { return }

            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 2
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let title = view.annotation?.title {
            let indexOfPin = locationNamesArray.firstIndex(of: title!)
            getRoute(locationCoordsArray[indexOfPin!])
        }
    }
    
    // Delegate
//    func mapView(_ mapView: MKMapView,  rendererFor overlay: MKOverlay, didSelect view: MKAnnotationView) -> MKOverlayRenderer {
//
//        if let title = view.annotation?.title {
//            print("lmao")            // now do somthing with your event
//        }
//
//        let renderer = MKPolylineRenderer(overlay: overlay)
//        renderer.strokeColor = UIColor.blue
//        renderer.lineWidth = 2
//        return renderer
//    }
    
}
