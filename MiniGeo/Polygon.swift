//
//  Polygon.swift
//  MiniGeo
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

open class Polygon: Geometry {

    public private(set) var exteriorRing: LinearRing?
    public private(set) var interiorRings: [LinearRing]?
    
    public init (exteriorRing: LinearRing?, interiorRings: [LinearRing]?) {
        self.exteriorRing = exteriorRing
        self.interiorRings = (interiorRings ?? []).isEmpty ? nil : interiorRings
    }
}
