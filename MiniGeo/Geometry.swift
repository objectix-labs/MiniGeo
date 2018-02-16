//
//  Geometry.swift
//  MiniGeo
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

// Defines the interface for planar geometry objects such as Polygons, MultiPolygons and LinarRings
public protocol PlanarGeometry {
    
    // Tests, whether the specifiec coordinates is within the bounds of the geometry.
    func contains(coordinate: Coordinate2D) -> Bool
    
}

open class Geometry {
    
    // Creates a Geometry from the specified WKT string.
    open class func create(wktCoordinateString: String) -> Geometry? {
        return nil
    }
    
    // Calculates the centroid for this Geometry.
    open func centroid() -> Coordinate2D {
        fatalError("centroid() on Geometry is not implemented. Call subclass implementation instead.")
    }
    
    // Calculates the absolute area for this Geometry. This is 0 for all geometries besides Polygon, MultiPolygon and LinearRing.
    open func area() -> Double {
        return 0
    }
    
    // Calculates the bounding box (envelope) of the geometry. Returned tuple is (topLeftCoordinate, bottomRightCoordinate).
    open func envelope() -> (Coordinate2D, Coordinate2D) {
        fatalError("envelope() on Geometry is not implemented. Call subclass implementation instead.")
    }
}
