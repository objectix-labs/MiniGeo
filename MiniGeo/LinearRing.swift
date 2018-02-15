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
}
