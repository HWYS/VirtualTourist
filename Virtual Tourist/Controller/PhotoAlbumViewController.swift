//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Htet Wai Yan Swe on 1/12/22.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController{
    

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
        setupFetchedResultsController()
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
        mapView.isUserInteractionEnabled = false
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<PhotoAlbum> = PhotoAlbum.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(String(describing: pin))-pins")
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
        FlickrApiClient.getPhotos(lat: pin.latitude, long: pin.longitude)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    private func isLoadingData(_ isLoading: Bool){
        if isLoading {
            activityIndicator.startAnimating()
        }else {
            activityIndicator.stopAnimating()
        }
        newCollectionButton.isEnabled = !isLoading
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
}



extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
}
