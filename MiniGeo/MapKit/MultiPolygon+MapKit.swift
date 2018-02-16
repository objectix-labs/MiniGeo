//
//  MultiPolygon+MapKit.swift
//  MiniGeo
//
//  Created by Christian Rühl on 16.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation
import MapKit

public extension MultiPolygon {
    
    // Initializes MultiPolygon from a list of polygons.
    public convenience init(mapkitPolygons: [MKPolygon]) {
        assert(!mapkitPolygons.isEmpty)
        
        self.init(polygons: mapkitPolygons.map({ (mapkitPolygon) -> Polygon in
            return Polygon(mapkitPolygon: mapkitPolygon)
        }))
    }
    
    public func mapkitPolygons() -> [MKPolygon] {
        return geometries.map({ (geometry) -> MKPolygon in
            return (geometry as! Polygon).mapkitPolygon()
        })
    }
    
}
