//
//  LinearRing+MapKit.swift
//  MiniGeo
//
//  Created by Christian Rühl on 16.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation
import MapKit

public extension LinearRing {
    
    // Initializes a ring from a list of MKMapPoints.
    convenience init(mapkitPoints: [MKMapPoint]) {
        assert(!mapkitPoints.isEmpty)
        
        self.init(coordinates: mapkitPoints.map({ (mapPoint) -> Coordinate2D in
            return Coordinate2D(mapkitPoint: mapPoint)
        }))
    }
    
    // Initializes a ring from a MapKit Polygon (using its exterior boundary only).
    convenience init(mapkitPolygon: MKPolygon) {
        let points: [Coordinate2D] = Array(UnsafeBufferPointer(start: mapkitPolygon.points(), count: mapkitPolygon.pointCount)).map { (mapkitPoint) -> Coordinate2D in
            return Coordinate2D(mapkitPoint: mapkitPoint)
        }
        
        self.init(coordinates: points)
    }
    
    // Returns the coordinates of this geometry as MapKit points.
    func mapkitPoints() -> [MKMapPoint] {
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
