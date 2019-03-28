//
//  Polygon+MapKit.swift
//  MiniGeo
//
//  Created by Christian Rühl on 16.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation
import MapKit

public extension Polygon {
    
    // Initialized Polygon from MKPolygon (sets exterior polygon only)
    convenience init(mapkitPolygon: MKPolygon) {
        self.init(exteriorRing: LinearRing(mapkitPolygon: mapkitPolygon), interiorRings: nil)
    }
    
    // Initializes Polygon from MKPolygons.
    convenience init(exteriorMapkitPolygon: MKPolygon, interiorMapkitPolygons: [MKPolygon]?) {
        let exteriorRing: LinearRing = LinearRing(mapkitPolygon: exteriorMapkitPolygon)
        let interiorRings: [LinearRing]? = interiorMapkitPolygons?.map({ (mapkitPolygon) -> LinearRing in
            return LinearRing(mapkitPolygon: mapkitPolygon)
        })
        
        self.init(exteriorRing: exteriorRing, interiorRings: interiorRings)
    }
    
    func mapkitPolygon() -> MKPolygon {
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
