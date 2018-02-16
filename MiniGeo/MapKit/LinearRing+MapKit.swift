//
//  LinearRing+MapKit.swift
//  MiniGeo
//
//  Created by Christian Rühl on 16.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation
import MapKit

extension LinearRing {
    
    // Returns the coordinates of this geometry as MapKit points.
    open func mapkitPoints() -> [MKMapPoint] {
        return coordinates.map { (coordinate) -> MKMapPoint in
            return coordinate.mapkitPoint()
        }
    }
    
    // Creates a MKPolygon shape from this geometry
    func mapkitPolygon() -> MKPolygon {
        let points: [MKMapPoint] = mapkitPoints()
        return MKPolygon(points: UnsafePointer<MKMapPoint>(points), count: points.count)
    }
    
}
