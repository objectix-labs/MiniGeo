//
//  Coordinate2D+CoreLocation.swift
//  MiniGeo
//
//  Created by Christian Rühl on 16.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation
import CoreLocation

public extension Coordinate2D {
    
    // Initializes this coordinate from a CoreLocation coordinate
    public convenience init(coreLocationCoordinate: CLLocationCoordinate2D) {
        self.init(x: coreLocationCoordinate.longitude, y: coreLocationCoordinate.latitude)
    }
    
    // Returns this coordinate as CoreLocation coordinate
    public func coreLocationCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: y, longitude: x)
    }
    
    // Checks whether this coordinate is equal/very close to the specified CoreLocation coordinate
    public func equals(coreLocationCoordinate: CLLocationCoordinate2D) -> Bool {
        return fabs(x-coreLocationCoordinate.longitude) < 0.000001 && (y-coreLocationCoordinate.latitude) < 0.000001
    }
    
}
