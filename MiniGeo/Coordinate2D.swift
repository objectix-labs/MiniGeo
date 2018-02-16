//
//  Coordinate2D.swift
//  MiniGeo
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

open class Coordinate2D {
    public var x: Double = 0.0
    public var y: Double = 0.0
    
    public init(x: Double, y: Double) {
        self.x = x;
        self.y = y;
    }
    
    // Checks, whether this coordinate is equal to the specified coordinate.
    public func equals(coordinate: Coordinate2D) -> Bool {
        return x == coordinate.x && y == coordinate.y
    }
}
