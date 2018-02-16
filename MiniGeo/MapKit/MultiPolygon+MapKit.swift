//
//  MultiPolygon+MapKit.swift
//  MiniGeo
//
//  Created by Christian Rühl on 16.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation
import MapKit

extension MultiPolygon {
    
    open func mapkitPolygons() -> [MKPolygon] {
        return geometries.map({ (geometry) -> MKPolygon in
            return (geometry as! Polygon).mapkitPolygon()
        })
    }
    
}
