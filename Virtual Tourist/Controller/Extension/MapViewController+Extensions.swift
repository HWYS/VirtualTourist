//
//  MapViewController+Extensions.swift
//  Virtual Tourist
//
//  Created by Htet Wai Yan Swe on 1/11/22.
//

import Foundation
import MapKit

extension MapViewController  {
    
    func addAnnotationsToMap() {
        isLoadingData(isLoading: true)
        mapView.removeAnnotations(mapView.annotations)
        for pin in LocationPins.pins {
            
            var annotations = [MKPointAnnotation]()
            
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = pin.locationName
            annotations.append(annotation)
            mapView.addAnnotations(annotations)
        }
        
        isLoadingData(isLoading: false)
    }
    
    private func isLoadingData(isLoading: Bool){
        if isLoading {
            activityIndicator.startAnimating()
        }else {
            activityIndicator.stopAnimating()
        }
    }
    
    func addLogPressListenerToMap() {
        let longGesture = UILongPressGestureRecognizer()
        longGesture.minimumPressDuration = 0.2
        longGesture.addTarget(self, action: #selector(longPressed))
        mapView.addGestureRecognizer(longGesture)
    }
    
    @objc func longPressed(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizer.State.began {
            return
        }
        let point = gestureRecognizer.location(in: mapView)
        let coord = mapView.convert(point, toCoordinateFrom: mapView)
        getCityNameByCoordinate(coordinte: coord) { locationName in
            
            self.saveLocation(coordinte: coord, locationName: locationName)
        }
        
    }
    
    func getCityNameByCoordinate(coordinte: CLLocationCoordinate2D, completion: @escaping (String) -> Void){
        isLoadingData(isLoading: true)
        
        let location = CLLocation(latitude: coordinte.latitude, longitude: coordinte.longitude)
        let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (addressArray, error) in
               
                if (error) == nil {
                    if addressArray!.count > 0 {
                        let locationName = addressArray?[0].locality ?? "My Location"
                        
                        completion(locationName)
                        
                    }else {
                        self.isLoadingData(isLoading: false)
                        completion("My Location")
                    }
             }
            
        }
    }
    
    private func addAnnotation(coordinate: CLLocationCoordinate2D, locationName: String) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        annotation.title = locationName
        mapView.addAnnotation(annotation)
        
        saveLocation(coordinte: coordinate, locationName: locationName)
    }
    
    private func saveLocation(coordinte: CLLocationCoordinate2D, locationName: String) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinte.latitude
        pin.longitude = coordinte.longitude
        pin.creationDate = Date()
        pin.locationName = locationName
        
        
        LocationPins.pins.append(pin)
        //addAnnotationsToMap()
        
        try? dataController.viewContext.save()
        isLoadingData(isLoading: false)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
        }
        
    }
}
