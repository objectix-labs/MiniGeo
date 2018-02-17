//
//  MultiPolygon.swift
//  MiniGeo
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

open class MultiPolygon: GeometryCollection, PlanarGeometry {
    public init(polygons: [Polygon]) {
        super.init(geometries: polygons)
    }
    
    open private(set) lazy var area: Double = {
        // The area of a GeometryCollection is the sum of the areas of the contained geometries
        var totalArea: Double = 0.0
        
        for geometry in geometries {
            totalArea += (geometry as! Polygon).area
        }
        
        return totalArea
    }()
    
    override open private(set) lazy var centroid: Coordinate2D = {
        // The centroid of a GeometryCollection is defined as the average across all centroids of the contained geometries
        var sumx: Double = 0.0
        var sumy: Double = 0.0
        var nrCentroids: Double = 0.0
        
        for geometry in geometries {
            let centroid: Coordinate2D = geometry.centroid
            sumx += centroid.x
            sumy += centroid.y
            nrCentroids += 1.0
        }
        
        return Coordinate2D(x: sumx / nrCentroids, y: sumy / nrCentroids)
    }()
    
    override open private(set) lazy var envelope: (Coordinate2D, Coordinate2D) = {
        // Envelope is defined by the envelopes of the contained polygons.
        var minX: Double = 100000.0
        var minY: Double = 100000.0
        var maxX: Double = -100000.0
        var maxY: Double = -100000.0
        
        for polygon in geometries {
            let envelopeBox = polygon.envelope
        
            if envelopeBox.0.x < minX {
                minX = envelopeBox.0.x
            }
            if envelopeBox.1.x > maxX {
                maxX = envelopeBox.1.x
            }
            if envelopeBox.1.y < minY {
                minY = envelopeBox.1.y
            }
            if envelopeBox.0.y > maxY {
                maxY = envelopeBox.0.y
            }
        }
        
        return (Coordinate2D(x: minX, y: maxY), Coordinate2D(x: maxX, y: minY))
    }()
    
    public func contains(coordinate: Coordinate2D) -> Bool {
        // Coordinate is considered to be within, if ALL of the following conditions are met:
        
        // (1) Coordinate is within the envelope of this geometry
        let envelopeBox = envelope
        
        if coordinate.x < envelopeBox.0.x || coordinate.x > envelopeBox.1.x {
            return false
        }
        
        if coordinate.y < envelopeBox.1.y || coordinate.y > envelopeBox.0.y {
            return false
        }
        
        // (2) Coordinate is in at least one of the contained polygons
        for polygon in geometries {
            if (polygon as! Polygon).contains(coordinate: coordinate) {
                return true
            }
        }
        
        // At this point, we can be sure that the coordinate is NOT within this multipolygon.
        return false
    }
}
