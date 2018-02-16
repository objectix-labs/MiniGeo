# MiniGeo

### A simple Swift framework for dealing with geographic objects and functions.

## Features (work-in-progress)
Please note that this framework is very much early stage and work in progress. It is developed driven by our project requirements and needs, and while in ALPHA its API may change and break any time. Please use with caution.

* Pure SWIFT framework
* No dependencies to other 3rd-party frameworks or libraries, or any embedded legacy Obj-C code
* well tested
* Compatible with Carthage
* Supported Geometries: LinearRing, Polygon, MultiPolygon
* WKT Parsing of POLYGON and MULTIPOLYGON
* Fast Point-in-Polygon (PiP) test
* Geometry calculations: envelope, area and centroid
* MapKit support (through extensions)

## System Requirements
* XCode 9+
* Swift 4.1
* Carthage

## Installation
Please add the framework via your `Cartfile`.
```bash
gitgub "objectix-labs/MiniGeo" "master"
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
    let testCoordinate = Coordinate2D(x: 29.0, y: 13)
    print(polygon.contains(coordinate: testCoordinate))
}
```

Please also refer to the unit tests for further example on how to use this framework.
