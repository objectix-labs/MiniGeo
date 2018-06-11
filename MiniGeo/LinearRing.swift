//
//  LinearRing.swift
//  MiniGeo
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

open class LinearRing: Geometry, PlanarGeometry {
    public private(set) var coordinates: [Coordinate2D]
    
    public init(coordinates: [Coordinate2D]) {
        // At least three coordinates must have been specified
        assert(coordinates.count > 2)
        
        self.coordinates = coordinates
        
        // A Linear Ring must always meet the following constraint: the first and the last coordinate in its sequernce must be equal to make it closed.
        // Otherwise, it would be just a polyline.
        if let first = coordinates.first, let last = coordinates.last, !first.equals(coordinate: last) {
            // The first and the last coordinate are not equal -> add first coordinate as last one
            self.coordinates.append(first)
        }
    }
    
    open override var centroid: Coordinate2D {
        return _centroid
    }
    
    private lazy var _centroid: Coordinate2D = {
        // cf. https://en.wikipedia.org/wiki/Centroid#Centroid_of_a_polygon
        
        // A closed Polygon must consist of at least four vertices in order to have an area.
        if coordinates.count < 4 {
            fatalError("Linar Ring must have at least four points.")
        }

        var sumx: Double = 0.0
        var sumy: Double = 0.0
        
        for i in 0..<coordinates.count - 1 {
            let factor: Double = (coordinates[i].x * coordinates[i+1].y - coordinates[i+1].x * coordinates[i].y)
            sumx += (coordinates[i].x + coordinates[i+1].x) * factor
            sumy += (coordinates[i].y + coordinates[i+1].y) * factor
        }
        
        let area = self.signedArea()
        
        let cx = sumx / (6.0 * area)
        let cy = sumy / (6.0 * area)
        
        return Coordinate2D(x: cx, y: cy)
    }()
    
    open private(set) lazy var area: Double = {
        return fabs(signedArea())
    }()
    
    open override var envelope: (Coordinate2D, Coordinate2D) {
        return _envelope
    }
    
    private lazy var _envelope: (Coordinate2D, Coordinate2D) = {
        var minX: Double = 100000.0
        var minY: Double = 100000.0
        var maxX: Double = -100000.0
        var maxY: Double = -100000.0
        
        for coordinate in coordinates {
            if coordinate.x < minX {
                minX = coordinate.x
            }
            if coordinate.x > maxX {
                maxX = coordinate.x
            }
            if coordinate.y < minY {
                minY = coordinate.y
            }
            if coordinate.y > maxY {
                maxY = coordinate.y
            }
        }
        
        return (Coordinate2D(x: minX, y: maxY), Coordinate2D(x: maxX, y: minY))
    }()
    
    public func contains(coordinate: Coordinate2D) -> Bool {
        // The coordinate is considered to be within this geometry, if ALL of the
        // following conditions are met:
        // (1) The coordinate is within the bounding box (envelope) of this geometry
        if coordinate.x < envelope.0.x || coordinate.x > envelope.1.x {
            return false
        }
        
        if coordinate.y < envelope.1.y || coordinate.y > envelope.0.y {
            return false
        }
        
        // (2) The coordinate is within the ring
        // Implementation of this test is taken from
        // https://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
        let nvert: Int = coordinates.count - 1 // Last coordinate duplicates first!
        var i: Int = 0
        var j: Int = nvert - 1
        var c: Bool = false
        
        while i < nvert {
            let vertex1: Coordinate2D = coordinates[i]
            let vertex2: Coordinate2D = coordinates[j]
            
            if ((vertex1.y > coordinate.y) != (vertex2.y > coordinate.y)) {
                if (coordinate.x < ((vertex2.x - vertex1.x) * (coordinate.y - vertex1.y) /
                    (vertex2.y - vertex1.y) + vertex1.x)) {
                    c = !c
                }
            }
            
            // Advance to next loop iteration
            j = i
            i = i + 1
        }
        
        return c
    }
    
    private func signedArea() -> Double {
        // cf. https://en.wikipedia.org/wiki/Centroid#Centroid_of_a_polygon

        // A closed Polygon must consist of at least four vertices in order to have an area.
        if coordinates.count < 4 {
            return 0.0
        }
        
        var sum: Double = 0.0
        
        for i in 0..<coordinates.count - 1 {
            sum += coordinates[i].x * coordinates[i+1].y - coordinates[i+1].x * coordinates[i].y
        }
        
        return 0.5 * sum
    }
}
