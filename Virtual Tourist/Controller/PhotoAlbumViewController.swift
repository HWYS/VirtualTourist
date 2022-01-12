//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Htet Wai Yan Swe on 1/12/22.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<PhotoAlbum>!
    var pin: Pin!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addPinToMap()
    }
    
    
    private func addPinToMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotation.title = pin.locationName
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region =  MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<PhotoAlbum> = PhotoAlbum.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-pins")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func newCollectionButtonClick(_ sender: Any) {
    }
    
    private func getPhotoAlbum() {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PhotoAlbumViewController: MKMapViewDelegate {
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
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
}
