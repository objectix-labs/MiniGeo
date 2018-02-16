//
//  Polygon.swift
//  MiniGeo
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

open class Polygon: Geometry {

    public private(set) var exteriorRing: LinearRing
    public private(set) var interiorRings: [LinearRing]?
    
    public init (exteriorRing: LinearRing, interiorRings: [LinearRing]?) {
        self.exteriorRing = exteriorRing
        self.interiorRings = (interiorRings ?? []).isEmpty ? nil : interiorRings
    }
    
    open override func area() -> Double {
        // The area of a polygon is the area of the exterior ring subtracted by the areas of the
        // interior rings (which represent holes in the polygon by definition)
        let exteriorArea = exteriorRing.area()
        var interiorAreas = 0.0
        
        for ring in interiorRings ?? [] {
            interiorAreas += ring.area()
        }
        
        return exteriorArea - interiorAreas
    }
    
    open override func centroid() -> Coordinate2D {
        // Polygon's centroid is equal to the exterior ring's centroid (by definition)
        return exteriorRing.centroid()
    }
}
