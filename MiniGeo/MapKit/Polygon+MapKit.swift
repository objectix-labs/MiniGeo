//
//  Polygon+MapKit.swift
//  MiniGeo
//
//  Created by Christian Rühl on 16.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation
import MapKit

extension Polygon {
    
    open func mapkitPolygon() -> MKPolygon {
        // Exterior polygon
        let exteriorPoints: [MKMapPoint] = exteriorRing.mapkitPoints()
        
        // Interior Polygons
        var interiorPolygons: [MKPolygon]? = nil
        
        if !(interiorRings ?? []).isEmpty {
            interiorPolygons = []
            
            for ring in interiorRings! {
                interiorPolygons!.append(ring.mapkitPolygon())
            }
        }
        
        return MKPolygon(points: UnsafePointer<MKMapPoint>(exteriorPoints), count: exteriorPoints.count, interiorPolygons: interiorPolygons)
    }
    
}
