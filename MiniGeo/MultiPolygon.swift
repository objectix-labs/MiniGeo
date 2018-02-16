//
//  MultiPolygon.swift
//  MiniGeo
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

open class MultiPolygon: GeometryCollection {
    public init(polygons: [Polygon]) {
        super.init(geometries: polygons)
    }
    
    open override func area() -> Double {
        // The area of a MultiPolygon is the sum of the areas of the contained polygons
        var totalArea: Double = 0.0
        
        for polygon in geometries {
            totalArea += polygon.area()
        }
        
        return totalArea
    }
    
    open override func centroid() -> Coordinate2D {
        // The centroid of a MultiPolygon is defined as the average across all centroids of the contained polygons.
        var sumx: Double = 0.0
        var sumy: Double = 0.0
        var nrCentroids: Double = 0.0
        
        for polygon in geometries {
            let centroid: Coordinate2D = polygon.centroid()
            sumx += centroid.x
            sumy += centroid.y
            nrCentroids += 1.0
        }
        
        return Coordinate2D(x: sumx / nrCentroids, y: sumy / nrCentroids)
    }
}
