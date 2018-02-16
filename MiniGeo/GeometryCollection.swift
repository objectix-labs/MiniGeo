//
//  GeometryCollection.swift
//  MiniGeo
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

open class GeometryCollection: Geometry {
    public private(set) var geometries: [Geometry]
    
    public init(geometries: [Geometry]) {
        self.geometries = geometries
    }
    
    open override func area() -> Double {
        // The area of a GeometryCollection is the sum of the areas of the contained geometries
        var totalArea: Double = 0.0
        
        for geometry in geometries {
            totalArea += geometry.area()
        }
        
        return totalArea
    }
    
    open override func centroid() -> Coordinate2D {
        // The centroid of a GeometryCollection is defined as the average across all centroids of the contained geometries
        var sumx: Double = 0.0
        var sumy: Double = 0.0
        var nrCentroids: Double = 0.0
        
        for geometry in geometries {
            let centroid: Coordinate2D = geometry.centroid()
            sumx += centroid.x
            sumy += centroid.y
            nrCentroids += 1.0
        }
        
        return Coordinate2D(x: sumx / nrCentroids, y: sumy / nrCentroids)
    }
}
