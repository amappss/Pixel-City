//
//  DroppablePin.swift
//  pixel_city
//
//  Created by Arsalan majlesi on 6/12/21.
//

import UIKit
import MapKit

class DroppablePin : NSObject, MKAnnotation{
    dynamic let coordinate: CLLocationCoordinate2D
    let identifier : String
    
    init(coordinate:CLLocationCoordinate2D,identifier:String) {
        self.coordinate = coordinate
        self.identifier = identifier
    }
}
