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
    
    let itemsPerRow: CGFloat = 2
    let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        noImagesLabel.isHidden = true
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
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-photos")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            getPhotosFromDb()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
        if fetchedResultsController.sections![0].numberOfObjects < 0 {
            getPhotosFromApi()
        }
    }
    
    private func getPhotosFromDb(){
        isLoadingData(false)
        if let resutls = fetchedResultsController.fetchedObjects {
            DataModel.photos = resutls
            
            if resutls.isEmpty {
                getPhotosFromApi()
            }
        }
    }
    
    @IBAction func newCollectionButtonClick(_ sender: Any) {
        deleteFromDb()
        
    }
    
    private func getPhotosFromApi() {
        if isConnectedToInternet {
            isLoadingData(true)
            FlickrApiClient.getPhotos(lat: pin.latitude, lon: pin.longitude) { photoIds, error in
                if photoIds.count > 0 {
                    self.savePhotos(photoIds: photoIds) {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.isLoadingData(false)
                        }
                    }
                
                }else {
                    self.noImagesLabel.isHidden = false
                    self.isLoadingData(false)
                }
            }
        }else {
            showAlert(message: "Internet connection is not available")
        }
    
    }
    
    private func savePhotos(photoIds: [Photo], completion: @escaping () -> Void) {
        
        for item in photoIds {
            let photo = PhotoAlbum(context: self.dataController.viewContext)
            photo.pin = self.pin
            photo.creationDate = Date()
            photo.photoURL = "https://farm\(item.farmNumber).staticflickr.com/\(item.serverId)/\(item.id)_\(item.secret).jpg"
            /*let imageUrl = URL(string: photo.photoURL!)
            if let data = try? Data(contentsOf: imageUrl!) {
                photo.photo = data
            }*/
            try? self.dataController.viewContext.save()
            DataModel.photos.append(photo)
            
        }
        
        completion()
    }
    
    private func deleteFromDb() {
        if let photos = fetchedResultsController.fetchedObjects {
            DataModel.photos.removeAll()
            for photo in photos {
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                } catch {
                    debugPrint("Error Deleting All Photo")
                }
            }
        }
        getPhotosFromApi()
    }
   
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
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            //collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        default: ()
        }
    }
    
}
