//
//  Geometry.swift
//  MiniGeo
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

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
}
