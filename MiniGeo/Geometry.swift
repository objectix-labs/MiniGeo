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
    // Returns the absolute area for this Geometry. This is 0 for all geometries besides Polygon, MultiPolygon and LinearRing.
    var area: Double { get }

    // Tests, whether the specific coordinates is within the bounds of the geometry.
    func contains(coordinate: Coordinate2D) -> Bool
}

open class Geometry: Hashable {
    // Creates a Geometry instance from the specified WKT string. Returns nil, if WKT string could not be parsed successfully.
    open class func create(fromWKT input: String) -> Geometry? {
        let wktReader: WKTReader = WKTReader()
        return wktReader.parse(wktString: input)
    }
    
    // Calculates the centroid for this Geometry.
    open var centroid: Coordinate2D {
        fatalError("centroid() on Geometry is not implemented. Call subclass implementation instead.")
    }
    
    // Calculates the bounding box (envelope) of the geometry. Returned tuple is (topLeftCoordinate, bottomRightCoordinate).
    open var envelope: (Coordinate2D, Coordinate2D) {
        fatalError("envelope() on Geometry is not implemented. Call subclass implementation instead.")
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    public static func ==(lhs: Geometry, rhs: Geometry) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
