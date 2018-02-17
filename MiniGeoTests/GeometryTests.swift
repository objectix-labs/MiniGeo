//
//  GeometryTests.swift
//  MiniGeoTests
//
//  Created by Christian Rühl on 16.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import XCTest
import CoreLocation
import MapKit
@testable import MiniGeo

class GeometryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLinearRing() {
        let points: [Coordinate2D] = [Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 20), Coordinate2D(x: 20, y: 0), Coordinate2D(x: 0, y: 0)]
        let ring: LinearRing = LinearRing(coordinates: points)
        
        // Test area
        let area = ring.area
        XCTAssertTrue(area == 200.0)
        
        // Test centroid
        let centroid = ring.centroid
        XCTAssertTrue(centroid.x == 10.0)
        XCTAssertEqual(centroid.y, 6.667, accuracy: 0.001, "Y coordinate of centroid must match")
        
        // Test point in polygon
        let contained = ring.contains(coordinate: Coordinate2D(x: 5, y: 5))
        XCTAssertTrue(contained)
        
        let notContained = ring.contains(coordinate: Coordinate2D(x: 1, y: 15))
        XCTAssertFalse(notContained)
        
        // Centroid should be within polygon
        XCTAssertTrue(ring.contains(coordinate: centroid))
    }
    
    func testLinearRingClosing() {
        // Linear rings must be always closed. If initialized with unclosed coordinate sequence, the linear ring should close itself upon initialization.
        let points: [Coordinate2D] = [Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 20), Coordinate2D(x: 20, y: 0)]
        let ring: LinearRing = LinearRing(coordinates: points)
        
        // Initialized ring should be closed now (i.e. the first coordinate should be added as last coordinate)
        XCTAssertTrue(ring.coordinates.count == 4)
        XCTAssertTrue(ring.coordinates.first!.equals(coordinate: ring.coordinates.last!))
    }
    
    func testEqualityOperators() {
        let coordinate1: Coordinate2D = Coordinate2D(x: 42.0, y: 44.0)
        let coordinate2: Coordinate2D = Coordinate2D(x: 42.0, y: 44.0)
        let coordinate3: Coordinate2D = Coordinate2D(x: 12.0, y: 17.0)
        
        XCTAssertTrue(coordinate1.equals(coordinate: coordinate2))
        XCTAssertFalse(coordinate1.equals(coordinate: coordinate3))
        
        let coreLocationCoordinate1: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 44.0, longitude: 42.0)
        let coreLocationCoordinate2: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 17.0, longitude: 12.0)
        
        XCTAssertTrue(coordinate1.equals(coreLocationCoordinate: coreLocationCoordinate1))
        XCTAssertFalse(coordinate1.equals(coreLocationCoordinate: coreLocationCoordinate2))

        let mapkitPoint1: MKMapPoint = MKMapPointForCoordinate(coreLocationCoordinate1)
        let mapkitPoint2: MKMapPoint = MKMapPointForCoordinate(coreLocationCoordinate2)
        
        XCTAssertTrue(coordinate1.equals(mapkitPoint: mapkitPoint1))
        XCTAssertFalse(coordinate1.equals(mapkitPoint: mapkitPoint2))
    }
    
    func testSimplePolygon() {
        let points: [Coordinate2D] = [Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 20), Coordinate2D(x: 20, y: 0), Coordinate2D(x: 0, y: 0)]
        let ring: LinearRing = LinearRing(coordinates: points)
        let polygon: Polygon = Polygon(exteriorRing: ring, interiorRings: nil)
        
        // Test area
        let area = polygon.area
        XCTAssertTrue(area == 200.0)
        
        // Test centroid
        let centroid = polygon.centroid
        XCTAssertTrue(centroid.x == 10.0)
        XCTAssertEqual(centroid.y, 6.667, accuracy: 0.001, "Y coordinate of centroid must match")
        
        // Test point in polygon
        let contained = polygon.contains(coordinate: Coordinate2D(x: 5, y: 5))
        XCTAssertTrue(contained)
        
        let notContained = polygon.contains(coordinate: Coordinate2D(x: 1, y: 15))
        XCTAssertFalse(notContained)
        
        // Centroid should be within polygon
        XCTAssertTrue(polygon.contains(coordinate: centroid))
    }
    
    func testSimpleMultiPolygon() {
        let points1: [Coordinate2D] = [Coordinate2D(x: 0, y: 0), Coordinate2D(x: 10, y: 20), Coordinate2D(x: 20, y: 0), Coordinate2D(x: 0, y: 0)]
        let ring1: LinearRing = LinearRing(coordinates: points1)
        let polygon1: Polygon = Polygon(exteriorRing: ring1, interiorRings: nil)

        let points2: [Coordinate2D] = [Coordinate2D(x: 0, y: 0), Coordinate2D(x: -10, y: -20), Coordinate2D(x: -20, y: 0), Coordinate2D(x: 0, y: 0)]
        let ring2: LinearRing = LinearRing(coordinates: points2)
        let polygon2: Polygon = Polygon(exteriorRing: ring2, interiorRings: nil)

        let multiPolygon: MultiPolygon = MultiPolygon(polygons: [polygon1, polygon2])
        
        // Test area
        let area = multiPolygon.area
        XCTAssertTrue(area == 400.0)
        
        // Test centroid
        let centroid = multiPolygon.centroid
        XCTAssertEqual(centroid.x, 0, accuracy: 0.001, "X coordinate of centroid must match")
        XCTAssertEqual(centroid.y, 0, accuracy: 0.001, "Y coordinate of centroid must match")
        
        // Test point in polygon
        let contained = multiPolygon.contains(coordinate: Coordinate2D(x: 5, y: 5))
        XCTAssertTrue(contained)
        
        let notContained = multiPolygon.contains(coordinate: Coordinate2D(x: 1, y: 15))
        XCTAssertFalse(notContained)
        
        // Centroid should be within multi polygon
        XCTAssertTrue(multiPolygon.contains(coordinate: centroid))
    }
    
}
