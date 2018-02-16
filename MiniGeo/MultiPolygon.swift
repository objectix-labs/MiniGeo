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
}
