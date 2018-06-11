# MiniGeo

### A simple Swift framework for dealing with geographic objects and functions on iOS.

[![Build Status](https://travis-ci.org/objectix-labs/MiniGeo.svg?branch=develop)](https://travis-ci.org/objectix-labs/MiniGeo)
![platform](https://img.shields.io/badge/platform-iOS-lightgray.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features (work-in-progress)
**Please note that this framework is very much early stage and work in progress. It is developed driven by our project requirements and needs, and while in ALPHA its API may change and break any time. Please use with caution.**

* 100% pure SWIFT framework (no-hidden ObjC or C code)
* No dependencies to other 3rd-party frameworks or libraries, or any embedded legacy Obj-C code
* Well tested (Unit Tests)
* Compatible with Carthage
* Supported Geometries: LinearRing, Polygon, MultiPolygon
* WKT Parsing of POLYGON and MULTIPOLYGON
* Fast Point-in-Polygon (PiP) test
* Quad Tree implementation for efficient geometry lookup by a given coordinate (eg. for performing very fast hit test on large geometry sets)
* Geometry calculations: envelope, area and centroid
* Coordinate equality (two coordinates are considered equal if difference per component is less than 0.000001)
* MapKit support (through extensions)
* CoreLocation support (through extensions)

## System Requirements
* XCode 9.4+
* Swift 4.1+
* Carthage
* iOS 9.0+

## Installation
Please add the framework via your `Cartfile`:
```bash
github "objectix-labs/MiniGeo" "0.3.0"
```

If you feel adventurous you can also use the latest development snapshot instead:
```bash
github "objectix-labs/MiniGeo" "develop"
````

## Getting started

```swift
import MiniGeo

...
// Parse a WKT string
let wktString = "POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))"
if let polygon = Geometry.create(fromWKT: wktString) as? Polygon {
    // Do some stuff with polygon
    print(polygon.area)
    print(polygon.envelope)

    // Test PiP
    let testCoordinate = Coordinate2D(x: 29.0, y: 13.0)
    print(polygon.contains(coordinate: testCoordinate))

    // Centroid should be within polygon
    let centroid = polygon.centroid
    print(polygon.contains(coordinate: centroid))

    // Test equality of two coordinates
    let testCoordinate2 = Coordinate2D(x: 29.0, y: 13.0)
    print(testCoordinate2.equals(coordinate: testCoordinate))

    /*
        Accelerated hit testing with Quad Tree.
        Performance tests with randomized data set of 10000 geometries with 10000 random coordinate 
        lookups indicates an acceleration factor of 70 and more! YMMV
    */
    let veryLargeGeometrySet: Set<Geometry> = ...

    // Initialize quad tree for data set (done only once for a given set!)
    let quadTree = QuadTree()
    quadTree.build(from: veryLargeGeometrySet)

    // Lookup "nearby" geometries for test coordinate
    let proximityGeometries = quadTree.fetch(for: testCoordinate)

    // Perform hit test with candidate geometries (rather than all geometries in data set)
    for geometry in proximityGeometries {
        print(geometry.contains(coordinate: testCoordinate))
    }
}
```

Please also refer to the unit tests for further example on how to use this framework.

## Todos (in no particular order)
* support for additional Geometries (eg. Point, LineString, ...)
* more geometric operations (e.g. polygon buffering, convex hull, ...)
* more tests
* performance improvements in WKT parsing
* support for WKB (binary version of WKT)
* support for macOS
