//
//  ImageCollectionViewController.swift
//  VirtualTourist_YY
//
//  Created by MacAir11 on 2019/12/20.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fetchedResultsController: NSFetchedResultsController<Image>!
    
    //var dataController: DataController!
    
    var context: NSManagedObjectContext{
        return DataController.shared.viewContext
    }
    
    var havePhotos: Bool{
        return(fetchedResultsController.fetchedObjects?.count ?? 0) != 0
    }
    
    var isDeletingAll = false
    var pin: Pin!
    var pageNumber = 0
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        let img = fetchedResultsController.object(at: indexPath)
        cell.setImage(img)
        cell.activityIndicator.isHidden = false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let img = fetchedResultsController.object(at: indexPath)
        print("indexPath : ",indexPath)
        context.delete(img)
        try? context.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width-20) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        setupMapView()
        noImageLabel.isHidden = true
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupMapView() {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: pin.coordinate, span: span)
        mapView.setRegion(region, animated: false)
        
        let currentMapRect = mapView.visibleMapRect
        
        var topPadding: CGFloat = 0
        if let safeAreaTopInset = UIApplication.shared.keyWindow?.safeAreaInsets.top,
            let navigationBarHeight = navigationController?.navigationBar.frame.height {
            topPadding = safeAreaTopInset + navigationBarHeight
        }
        
        let padding = UIEdgeInsets(top: topPadding, left: 0.0, bottom: 0.0, right: 0.0)
        mapView.setVisibleMapRect(currentMapRect, edgePadding: padding, animated: true)
        mapView.addAnnotation(pin)
        
        mapView.isUserInteractionEnabled = false
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let indexPath = indexPath, type == .delete && !isDeletingAll{
            collectionView.deleteItems(at: [indexPath])
            return
        }
        
        if let indexPath = indexPath, type == .insert{
            collectionView.insertItems(at: [indexPath])
            return
        }
        
        if let newIndexPath = newIndexPath, let oldIndexPath = indexPath, type == .move{
            collectionView.moveItem(at: oldIndexPath, to: newIndexPath)
            return
        }
        
        if type != .update {
            collectionView.reloadData()
        }
    }
    
    func setupFetchedResultsController(){
        fetchedResultsController = nil
        let fetchRequest : NSFetchRequest<Image> = Image.fetchRequest()
        
        let predicate = NSPredicate(format: "pin = %@", pin)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
        
        do{
            try? fetchedResultsController.performFetch()
        }
        catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    
    func updateUI(processing: Bool){
        collectionView.isUserInteractionEnabled = !processing
        if processing{
            barButton.title = ""
        }else{
            barButton.title = "New Collection"
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }
    
    func configureMap(){
        mapView.delegate = self
        
        addAnnotation(pin)
        
        
        //set the map region
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let center = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func showNoImageLabel(_ showLabel:Bool){
        noImageLabel.isHidden = !showLabel
        collectionView.isHidden = showLabel
    }

    
    @IBAction func showNewCollection(_ sender: UIBarButtonItem) {
        updateUI(processing: true)

        showFlickrImages()

    }
    
    func showFlickrImages() {
        if havePhotos{
            isDeletingAll = true
            for img in fetchedResultsController.fetchedObjects!{
                context.delete(img)
            }
            try? context.save()
            isDeletingAll = false
        }
        
//        FlickrAPI.getUrl(with: pin.coordinate, numOfPage: pageNumber+1) { (url, error, errorMessage) in
        VTClient.getURLForLocation(latitude: pin.latitude, longitude: pin.longitude, numOfPage: pageNumber+1) { (url, error, errorMessage) in
            DispatchQueue.main.async {
                self.updateUI(processing: false)
                guard (error == nil) && (errorMessage == nil) else{
                    fatalError("The images could not be loade: \(error?.localizedDescription)")
                    return
                }
                guard let url = url, !url.isEmpty else{
                    self.showNoImageLabel(true)
                    return
                }
                
                self.showNoImageLabel(false)
                
                for _url in url{
                    let img = Image(context: self.context)
                    img.imageURL = _url
                    img.pin = self.pin
                }
                try? self.context.save()
            }
        }
        pageNumber += 1
    }
    
}

extension CollectionViewController:MKMapViewDelegate{
    func addAnnotation(_ pin:Pin){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        DispatchQueue.main.async {
            //add pin to map
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pin!.canShowCallout = true
            pin!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pin!.annotation = annotation
        }
        
        return pin
    }
}
