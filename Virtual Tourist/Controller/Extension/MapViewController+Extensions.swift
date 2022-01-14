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
        for pin in DataModel.pins {
            
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
        if isConnectedToInternet {
            let point = gestureRecognizer.location(in: mapView)
            let coord = mapView.convert(point, toCoordinateFrom: mapView)
            saveLocation(coordinte: coord)
        }else {
            showAlert(message: "Intenet connection is not available")
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
    
    
    
    private func saveLocation(coordinte: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinte.latitude
        pin.longitude = coordinte.longitude
        pin.creationDate = Date()
        
        
        getCityNameByCoordinate(coordinte: coordinte) { location in
            pin.locationName = location
            DataModel.pins.append(pin)
            try? self.dataController.viewContext.save()
            self.addAnnotationsToMap()
        }
    }
    
    func saveRegion(withKey key:String) {
        let locationData = [mapView.region.center.latitude, mapView.region.center.longitude,
                            mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta]
        defaults.set(locationData, forKey: key)
    }
    
    func loadRegion(withKey key:String) -> MKCoordinateRegion? {
        guard let region = defaults.object(forKey: key) as? [Double] else { return nil }
        let center = CLLocationCoordinate2D(latitude: region[0], longitude: region[1])
        let span = MKCoordinateSpan(latitudeDelta: region[2], longitudeDelta: region[3])
        return MKCoordinateRegion(center: center, span: span)
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
            let destination = self.storyboard?.instantiateViewController(identifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
            destination.dataController = self.dataController
            let pin = DataModel.pins.first(where: {$0.latitude == view.annotation?.coordinate.latitude})
           
            destination.pin = pin
            self.navigationController?.pushViewController(destination, animated: true)
        }
        
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        saveRegion(withKey: "mapregion")
    }
}
