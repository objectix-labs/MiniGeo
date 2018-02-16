//
//  WKTParsingTests.swift
//  MiniGeoTests
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import XCTest
@testable import MiniGeo

class WKTParsingTests: XCTestCase {
    
    private var wktReader: WKTReader!
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        wktReader = WKTReader()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSplit() {
        let tokens = wktReader.split(string: "42 43 44 45", by: "[ ]+")
        XCTAssertTrue(tokens.count == 4)
        XCTAssertTrue(tokens[0] == "42")
        XCTAssertTrue(tokens[1] == "43")
        XCTAssertTrue(tokens[2] == "44")
        XCTAssertTrue(tokens[3] == "45")
    }
    
    func testMatch() {
        let matches: [String] = wktReader.match(string: "42 43 44 45", by: "\\d+")
        XCTAssertTrue(matches.count == 4)
        XCTAssertTrue(matches[0] == "42")
        XCTAssertTrue(matches[1] == "43")
        XCTAssertTrue(matches[2] == "44")
        XCTAssertTrue(matches[3] == "45")
    }
    
    func testMatchGroups() {
        let matches: [String] = wktReader.matchGroups(string: "(12)", by: "\\((\\d+)\\)")
        XCTAssertTrue(matches.count == 1)
        XCTAssertTrue(matches[0] == "12")
        
        let matches2: [String] = wktReader.matchGroups(string: "(some text here)", by: "\\((.*)\\)")
        XCTAssertTrue(matches2.count == 1)
        XCTAssertTrue(matches2[0] == "some text here")
    }
    
    func testValidCoordinatePairs() {
        let coordinate: Coordinate2D? = wktReader.parseCoordinatePair(wktInput: "32.12 64.14")
        XCTAssertNotNil(coordinate)
        XCTAssertTrue(coordinate!.x == 32.12)
        XCTAssertTrue(coordinate!.y == 64.14)
        
        let coordinate2: Coordinate2D? = wktReader.parseCoordinatePair(wktInput: "-32.12    64.14")
        XCTAssertNotNil(coordinate2)
        XCTAssertTrue(coordinate2!.x == -32.12)
        XCTAssertTrue(coordinate2!.y == 64.14)
    }
    
    func testInvalidCoordinatePairs() {
        let coordinate: Coordinate2D? = wktReader.parseCoordinatePair(wktInput: "32.12/64.14")
        XCTAssertNil(coordinate)
        
        let coordinate2: Coordinate2D? = wktReader.parseCoordinatePair(wktInput: "32G 64.14")
        XCTAssertNil(coordinate2)
        
        let coordinate3: Coordinate2D? = wktReader.parseCoordinatePair(wktInput: "32.12")
        XCTAssertNil(coordinate3)
    }
    
    func testValidCoordinateSequences() {
        let seq: [Coordinate2D]? = wktReader.parseCoordinateSequence(wktInput: "(1 2,3   4,  5      6)")
        XCTAssertNotNil(seq)
        XCTAssertTrue(seq!.count == 3)
        XCTAssertTrue(seq![0].x == 1.0)
        XCTAssertTrue(seq![0].y == 2.0)
        XCTAssertTrue(seq![1].x == 3.0)
        XCTAssertTrue(seq![1].y == 4.0)
        XCTAssertTrue(seq![2].x == 5.0)
        XCTAssertTrue(seq![2].y == 6.0)
        
        let seq2: [Coordinate2D]? = wktReader.parseCoordinateSequence(wktInput: "()")
        XCTAssertNotNil(seq2)
        XCTAssertTrue(seq2!.isEmpty)
        
        let seq3: [Coordinate2D]? = wktReader.parseCoordinateSequence(wktInput: "(1 2)")
        XCTAssertNotNil(seq3)
        XCTAssertTrue(seq3!.count == 1)
        XCTAssertTrue(seq3![0].x == 1.0)
        XCTAssertTrue(seq3![0].y == 2.0)
        
        let seq4: [Coordinate2D]? = wktReader.parseCoordinateSequence(wktInput: "(1 2, 3 4, 5 6)")
        XCTAssertNotNil(seq4)
        XCTAssertTrue(seq4!.count == 3)
        XCTAssertTrue(seq4![0].x == 1.0)
        XCTAssertTrue(seq4![0].y == 2.0)
        XCTAssertTrue(seq4![1].x == 3.0)
        XCTAssertTrue(seq4![1].y == 4.0)
        XCTAssertTrue(seq4![2].x == 5.0)
        XCTAssertTrue(seq4![2].y == 6.0)
    }
    
    func testValidPolygon() {
        let polygon: Polygon? = wktReader.parse(wktString: "POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))") as? Polygon
        XCTAssertNotNil(polygon)
        XCTAssertNotNil(polygon!.exteriorRing)
        XCTAssertNil(polygon!.interiorRings)
        
        let polygon2: Polygon? = wktReader.parse(wktString: "POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10), (20 30, 35 35, 30 20, 20 30))") as? Polygon
        XCTAssertNotNil(polygon2)
        XCTAssertNotNil(polygon2!.exteriorRing)
        XCTAssertNotNil(polygon2!.interiorRings)
    }
    
    func testValidMultiPolygon() {
        let multipolygon: MultiPolygon? = wktReader.parse(wktString: "MULTIPOLYGON (((40 40, 20 45, 45 30, 40 40)), ((20 35, 10 30, 10 10, 30 5, 45 20, 20 35), (30 20, 20 15, 20 25, 30 20)))") as? MultiPolygon
        XCTAssertNotNil(multipolygon)
        XCTAssertNotNil(multipolygon?.geometries)
        XCTAssertTrue(multipolygon!.geometries!.count == 2)
        
        let poly1 = multipolygon!.geometries![0] as! Polygon
        let poly2 = multipolygon!.geometries![1] as! Polygon

        XCTAssertTrue(poly1.exteriorRing!.coordinates.count == 4)
        XCTAssertNil(poly1.interiorRings)

        XCTAssertTrue(poly2.exteriorRing!.coordinates.count == 6)
        XCTAssertNotNil(poly2.interiorRings)
        XCTAssertTrue(poly2.interiorRings!.count == 1)
    }
    
}
