//
//  Polygon.swift
//  MiniGeo
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

open class Polygon: Geometry, PlanarGeometry {

    public let exteriorRing: LinearRing
    public let interiorRings: [LinearRing]?
    
    public init (exteriorRing: LinearRing, interiorRings: [LinearRing]?) {
        self.exteriorRing = exteriorRing
        self.interiorRings = (interiorRings ?? []).isEmpty ? nil : interiorRings
    }
    
    open private(set) lazy var area: Double = {
        // The area of a polygon is the area of the exterior ring subtracted by the areas of the
        // interior rings (which represent holes in the polygon by definition)
        let exteriorArea = exteriorRing.area
        var interiorAreas = 0.0
        
        for ring in interiorRings ?? [] {
            interiorAreas += ring.area
        }
        
        return exteriorArea - interiorAreas
    }()
    
    open override var centroid: Coordinate2D {
        return _centroid
    }
    
    private lazy var _centroid: Coordinate2D = {
        // Polygon's centroid is equal to the exterior ring's centroid (by definition)
        return exteriorRing.centroid
    }()
    
    open override var envelope: (Coordinate2D, Coordinate2D) {
        return _envelope
    }
    
    private lazy var _envelope: (Coordinate2D, Coordinate2D) = {
        // Envelope of Polygon is defined by exterior ring (by definition)
        return exteriorRing.envelope
    }()
    
    public func contains(coordinate: Coordinate2D) -> Bool {
        return contains(coordinate: coordinate, limitToExteriorBoundary: false)
    }
    
    public func contains(coordinate: Coordinate2D, limitToExteriorBoundary: Bool = false) -> Bool {
        // The coordinate is considered to be within this geometry, if ALL of the
        // following conditions are met:
        // (1) The coordinate is within the exterior ring
        if !exteriorRing.contains(coordinate: coordinate) {
            return false
        }
        
        // (2) The coordinate is NOT in any of the interior rings (if boolean flag is set to false)
        if !limitToExteriorBoundary {
            for ring in interiorRings ?? [] {
                if ring.contains(coordinate: coordinate) {
                    // Coordinate is within a hole of this polygon
                    return false
                }
            }
        }
        
        // At this point, we can be sure that coordinate is within exterior ring and not
        // within one of the "holes"
        return true
    }
}
