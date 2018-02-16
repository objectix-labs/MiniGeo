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
    
    public convenience init(mapkitPoint: MKMapPoint) {
        self.init(coreLocationCoordinate: MKCoordinateForMapPoint(mapkitPoint))
    }
    
    // Returns a MapKit Point for the given coordinate
    public func mapkitPoint() -> MKMapPoint {
        return MKMapPointForCoordinate(coreLocationCoordinate())
    }
    
}
