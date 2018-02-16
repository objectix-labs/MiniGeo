# MiniGeo

### A simple Swift framework for dealing with geographic objects and functions.

## Features (work-in-progress)
**Please note that this framework is very much early stage and work in progress. It is developed driven by our project requirements and needs, and while in ALPHA its API may change and break any time. Please use with caution.**

* 100% pure SWIFT framework (no-hidden ObjC or C code)
* No dependencies to other 3rd-party frameworks or libraries, or any embedded legacy Obj-C code
* Well tested (Unit Tests)
* Compatible with Carthage
* Supported Geometries: LinearRing, Polygon, MultiPolygon
* WKT Parsing of POLYGON and MULTIPOLYGON
* Fast Point-in-Polygon (PiP) test
* Geometry calculations: envelope, area and centroid
* Coordinate equality (two coordinates are considered equal if difference per component is less than 0.000001)
* MapKit support (through extensions)
* CoreLocation support (through extensions)

## System Requirements
* XCode 9+
* Swift 4.1
* Carthage

## Installation
Please add the framework via your `Cartfile`:
```bash
github "objectix-labs/MiniGeo" "master"
```

## Getting started

```swift
import MiniGeo

...
// Parse a WKT string
let wktString = "POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))"
if let polygon = Geometry.create(fromWKT: wktString) as? Polygon {
    // Do some stuff with polygon
    print(polygon.area())
    print(polygon.centroid())
    print(polygon.envelope())
    
    // Test PiP
    let testCoordinate = Coordinate2D(x: 29.0, y: 13.0)
    print(polygon.contains(coordinate: testCoordinate))

    // Test equality of two coordinates
    let testCoordinate2 = Coordinate2D(x: 29.0, y: 13.0)
    print(testCoordinate2.equals(coordinate: testCoordinate))
}
```

Please also refer to the unit tests for further example on how to use this framework.

## Todos
* Support for more Geometries (eg. Point, LineString, ...)
* more geometric operations (e.g. polygon buffering, convex hull, ...)
* more tests
* performance improvements in WKT parsing