//
//  Pin+Extensions.swift
//  VirtualTourist_YY
//
//  Created by MacAir11 on 2019/12/21.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import MapKit

extension Pin: MKAnnotation {
    
    public var coordinate : CLLocationCoordinate2D{
        set{
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        get{
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    func compare(to cordinates: CLLocationCoordinate2D) -> Bool {
        return (latitude == cordinates.latitude && longitude == cordinates.longitude)
    }
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
