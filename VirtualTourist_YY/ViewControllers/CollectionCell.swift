//
//  CollectionCell.swift
//  VirtualTourist_YY
//
//  Created by MacAir11 on 2019/12/20.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit

class CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionCellImage: UIImageView!
    
    var imageURL : URL!
    let ImagesCache = NSCache<NSString, AnyObject>()
    
    func setImage(_ newImage: Image){
        if img != nil{
            return
        }
        img = newImage
    }

    private var img: Image! {
        didSet{
            if let image = img.get(){
               collectionCellImage.image = image
                return
            }
            guard let url = img.imageURL else{
                return
            }
            loadImage(with: url)
        }
    }
    
    func loadImage(with url: URL){
        imageURL = url
        
        if let cachedImage = ImagesCache.object(forKey: url.absoluteString as NSString) as? UIImage{
            collectionCellImage.image = cachedImage
            activityIndicator.isHidden = true
            return
        }
        self.activityIndicator.startAnimating()
        
        URLSession.shared.dataTask(with: url){(data, response, error) in
            if let error = error {
                fatalError("The image could not be loaded: \(error.localizedDescription)")
                return
            }
            guard let DownloadedImage = UIImage(data: data!) else{
                return
            }
            self.ImagesCache.setObject(DownloadedImage, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async {
                self.collectionCellImage.image = DownloadedImage
                self.img.set(image: DownloadedImage)
                try? self.img.managedObjectContext?.save()
            }
            }.resume()
        
        self.activityIndicator.stopAnimating()
    }

}
