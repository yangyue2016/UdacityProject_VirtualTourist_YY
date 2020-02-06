//
//  ViewController.swift
//  VirtualTourist_YY
//
//  Created by MacAir11 on 2019/12/17.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    //var dataController: DataController!
    
    var annotations = [MKPointAnnotation]()

    func setupFetchedResultsController(){

        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do{
            try? fetchedResultsController.performFetch()
            print("updateMapView")
            updateMapView()
        }
        catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        //navigationItem.rightBarButtonItem = editButtonItem
        setupFetchedResultsController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        setupFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }

    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        
        let touchPoint = sender.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        print(coordinate.latitude, coordinate.longitude)
        
        addPin(longitude: coordinate.longitude, latitude: coordinate.latitude)
        
    }
    
    @IBAction func clickEdit(_ sender: UIBarButtonItem) {
        performSegue (withIdentifier: "gotoMapEditVC", sender: nil)
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        if let annotation = view.annotation {
            
            print("annotation:",annotation.coordinate.latitude, annotation.coordinate.longitude)
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [annotation.coordinate.latitude, annotation.coordinate.longitude])
            fetchRequest.predicate = predicate
            
            do {
                if let result = try DataController.shared.viewContext.fetch(fetchRequest) as? [Pin], let pin = result.first {
//                    print("delete pin")
//                    context.delete(pin)
//                    try context.save()
//                    updateMapView()
                    performSegue (withIdentifier: "gotoImageCollectionVC", sender: pin)
                    
                }
            } catch {
                print("Couldn't find any Pins")
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIButton
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func addPin(longitude: Double, latitude: Double) {
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = latitude
        annotation.coordinate.longitude = longitude
        mapView.addAnnotation(annotation)
        
        let pin = Pin(context: DataController.shared.viewContext)
        pin.longitude = longitude
        pin.latitude = latitude
        pin.creationDate = Date()
        try? DataController.shared.viewContext.save()
        
    }
    
    func updateMapView(){
        guard let pins = fetchedResultsController.fetchedObjects else {
            return
        }
        
        if !annotations.isEmpty {
            mapView.removeAnnotations(annotations)
            annotations.removeAll()
        }
        
        for pin in pins{
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude),longitude: CLLocationDegrees(pin.longitude))
            annotations.append(annotation)
        }
        
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoImageCollectionVC" {
            let imageCollectionVC = segue.destination as! CollectionViewController
            imageCollectionVC.pin = sender as? Pin
            //imageCollectionVC.dataController = self.dataController
        }
        
        if segue.identifier == "gotoMapEditVC" {
            let mapEditVC = segue.destination as! MapEditViewController
            //mapEditVC.dataController = self.dataController
        }
        
    }
 
}
