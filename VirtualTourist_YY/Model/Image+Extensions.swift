//
//  Image+Extensions.swift
//  VirtualTourist_YY
//
//  Created by MacAir11 on 2019/12/21.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit
extension Image{
    
    func set(image : UIImage){
        self.imageData = image.pngData()
    }
    func get() -> UIImage? {
        return (imageData == nil) ? nil : UIImage(data:imageData!)
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.creationDate = Date()
    }
}
