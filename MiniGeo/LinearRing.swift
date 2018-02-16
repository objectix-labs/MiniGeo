//
//  LinearRing.swift
//  MiniGeo
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

open class LinearRing: Geometry {
    public private(set) var coordinates: [Coordinate2D]
    
    public init(coordinates: [Coordinate2D]) {
        self.coordinates = coordinates
    }
    
    open override func centroid() -> Coordinate2D {
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
    }
    
    open override func area() -> Double {
        return fabs(signedArea())
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
