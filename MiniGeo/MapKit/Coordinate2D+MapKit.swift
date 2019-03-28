//
//  Coordinate2D+MapKit.swift
//  MiniGeo
//
//  Created by Christian Rühl on 16.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation
import MapKit

public extension Coordinate2D {
    
    convenience init(mapkitPoint: MKMapPoint) {
        self.init(coreLocationCoordinate: mapkitPoint.coordinate)
    }
    
    // Returns a MapKit Point for the given coordinate
    func mapkitPoint() -> MKMapPoint {
        return MKMapPoint.init(coreLocationCoordinate())
    }
    
    // Checks whether this coordinate is equal to the specified Mapkit point
    func equals(mapkitPoint: MKMapPoint) -> Bool {
        return self.equals(coordinate: Coordinate2D(mapkitPoint: mapkitPoint))
    }
    
}
