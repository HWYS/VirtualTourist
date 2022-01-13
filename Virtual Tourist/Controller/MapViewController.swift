//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Htet Wai Yan Swe on 1/7/22.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    var dataController: DataController!
    @IBOutlet weak var mapView: MKMapView!
    let defaults = UserDefaults.standard
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var fetchedResultsController:  NSFetchedResultsController<Pin>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpFetchResultsController()
        addLogPressListenerToMap()
        
        if let region = loadRegion(withKey: "mapregion") {
            mapView.region = region
        }
    }
    
    private func setUpFetchResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptior = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptior]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            getLocationsFromDb()
            
        }catch {
            fatalError("Cannot fetch to database: " + error.localizedDescription)
        }
    }
    
    private func getLocationsFromDb(){
        if let resutls = fetchedResultsController.fetchedObjects {
            LocationPins.pins = resutls
            addAnnotationsToMap()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        saveRegion(withKey: "mapregion")
    }
}



extension MapViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let _ = anObject as? Pin else {
            debugPrint("NOT A PIN")
            return
        }
        switch type {
        case .insert:
            DispatchQueue.main.async {
                //self.addAnnotationsToMap()
            }
            
            break
        default: break
        }
    }
}
