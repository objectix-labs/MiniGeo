//
//  Coordinate2D+MapKit.swift
//  MiniGeo
//
//  Created by Christian Rühl on 16.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

extension Coordinate2D {
    
    // Returns a MapKit Point for the given coordinate
    open func mapkitPoint() -> MKMapPoint {
        return MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: y, longitude: x))
    }
    
}
