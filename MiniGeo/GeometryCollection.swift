//
//  GeometryCollection.swift
//  MiniGeo
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

open class GeometryCollection: Geometry {
    public private(set) var geometries: [Geometry]?
    
    public init(geometries: [Geometry]?) {
        self.geometries = (geometries ?? []).isEmpty ? nil : geometries
    }
}
