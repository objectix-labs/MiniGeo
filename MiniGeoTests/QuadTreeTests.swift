//
//  QuadTreeTests.swift
//  MiniGeo
//
//  Created by Christian Rühl on 17.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import XCTest
@testable import MiniGeo

class QuadTreeTests: XCTestCase {
    
    private static var randomROIs: [(Geometry, Coordinate2D)]!
    
    override class func setUp() {
        // Create some random ROIs
        randomROIs = buildRandomGeometries(count: 1000)
    }
    

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmptyROISet() {
        let quadTree = QuadTree()
        
        // Build from empty set
        quadTree.build(from: Set<Geometry>())
        
        // Resulting quad tree should only have a root node which is also a leaf node at the same time
        XCTAssert(quadTree.depth == 1, "Quad Tree should have root node set after building.")
        XCTAssert(quadTree.nodeCount == 1, "Root node of quad tree should have no child nodes.")
    }
    
    func testSimpleROISet() {
        let quadTree = QuadTree()
        
        // Build from a single ROI
        let coords: [(Double, Double)] = [(-40.0, 0), (0.0, 40.0), (40.0, 0.0), (0.0, -40.0), (-40.0, 0.0)]
        let coordinates: [Coordinate2D] = coords.map { (long, lat) -> Coordinate2D in
            return Coordinate2D(x: long, y: lat)
        }
        let geometry: Geometry = LinearRing(coordinates: coordinates)
        
        quadTree.build(from: Set<Geometry>([geometry]))
        
        // Root node should be set
        XCTAssert(quadTree.depth == 1, "Quad Tree should have root node set after building.")
        XCTAssert(quadTree.nodeCount == 1, "Root node of quad tree should have no child nodes.")
        
        // Feed a coordinate that is for sure contained within ROI
        let testResult1 = quadTree.fetch(for: Coordinate2D(x: 0, y: 0))
        
        XCTAssertTrue(testResult1.count == 1, "Test result should contain the single ROI.")
    }
    
    func testComplexROISet() {
        let quadTree = QuadTree()
        
        let geometries = QuadTreeTests.randomROIs.map { (geometry, _) -> Geometry in
            return geometry
        }
        
        let centers = QuadTreeTests.randomROIs.map { (_, center) -> Coordinate2D in
            return center
        }
        
        // Build QuadTree from ROIs
        self.measure {
            quadTree.build(from: Set<Geometry>(geometries))
        }
        
        // Make sure root is set
        XCTAssert(quadTree.depth > 0, "Root of Quad tree must be set after build.")
        
        // For testing, we traverse each ROI, and generate a coordinate on the center of the ROI and make sure, we get the quad tree node, that contains that ROI.
        for (index, geometry) in geometries.enumerated() {
            let loc = centers[index]
            let geometries = quadTree.fetch(for: loc)
            
            XCTAssert(geometries.contains(geometry), "The quad tree lookup should have returned the current ROI.")
        }

    }
    
    func testPerformanceNonQuadTree() {
        // Perform test with old ROI Notification Service implementation (NO Quad Tree!)
        var coords: [Coordinate2D] = []
        let geometries = QuadTreeTests.randomROIs.map { (geometry, center) -> Geometry in
            coords.append(center)
            return geometry
        }
        
        roiHitTest(coordinates: coords) { coord in
            var nrHits: UInt = 0

            for geometry in geometries {
                if (geometry as! LinearRing).contains(coordinate: coord) {
                    nrHits += 1
                }
            }
            
            XCTAssertTrue(nrHits == 1, "Expected exactly one hit.")
        }
    }
    
    func testPerformanceQuadTree() {
        // Perform test with old ROI Notification Service implementation (NO Quad Tree!)
        var coords: [Coordinate2D] = []
        let geometries = QuadTreeTests.randomROIs.map { (geometry, center) -> Geometry in
            coords.append(center)
            return geometry
        }
        
        let quadTree = QuadTree()
        quadTree.build(from: Set<Geometry>(geometries))
        
        roiHitTest(coordinates: coords) { coord in
            let candidates = quadTree.fetch(for: coord)
            
            var nrHits: UInt = 0
            
            for geometry in candidates {
                if (geometry as! LinearRing).contains(coordinate: coord) {
                    nrHits += 1
                }
            }
            
            XCTAssertTrue(nrHits == 1, "Expected exactly one hit.")
        }
    }
    
    func testPerformanceNonQuadTreeRandom() {
        // Perform test with old ROI Notification Service implementation (NO Quad Tree!)
        var coords: [Coordinate2D] = []
        let geometries = QuadTreeTests.randomROIs.map { (geometry, _) -> Geometry in
            let long = QuadTreeTests.randomNumber(min: -180, max: 180)
            let lat = QuadTreeTests.randomNumber(min: -90, max: 90)
            coords.append(Coordinate2D(x: long, y: lat))
            return geometry
        }
        
        roiHitTest(coordinates: coords) { coord in
            // We need to check the current coordinate against each geometry
            var nrHits: UInt = 0
            
            for geometry in geometries {
                if (geometry as! LinearRing).contains(coordinate: coord) {
                    nrHits += 1
                }
            }
        }
    }
    
    func testPerformanceQuadTreeRandom() {
        // Perform test with old ROI Notification Service implementation (NO Quad Tree!)
        var coords: [Coordinate2D] = []
        let geometries = QuadTreeTests.randomROIs.map { (geometry, _) -> Geometry in
            let long = QuadTreeTests.randomNumber(min: -180, max: 180)
            let lat = QuadTreeTests.randomNumber(min: -90, max: 90)
            coords.append(Coordinate2D(x: long, y: lat))
            return geometry
        }
        
        let quadTree = QuadTree()
        quadTree.build(from: Set<Geometry>(geometries))
        
        roiHitTest(coordinates: coords) { coord in
            let candidates = quadTree.fetch(for: coord)
            // We need to check the current coordinate against each geometry
            var nrHits: UInt = 0
            
            for geometry in candidates {
                if (geometry as! LinearRing).contains(coordinate: coord) {
                    nrHits += 1
                }
            }
        }
    }

    
    private func roiHitTest(coordinates: [Coordinate2D], hitTest: @escaping (Coordinate2D) -> Void) {
        // Execute test after a few moments
        self.measure {
            for c in coordinates {
                hitTest(c)
            }
        }
    }
    
    // Provides a random number in the specified range
    static func randomNumber(min: Double, max: Double) -> Double {
        let scalar: Double = Double(arc4random()) / Double(UINT32_MAX)
        return (max - min) * scalar + min
    }
    
    static func buildRandomROI(identifier: String) -> (Geometry, Coordinate2D) {
        // Each ROI consist of a triangle region (asserts convex hull all the time), which is centered around a random coordinate
        
        // Random center coordinate (-160, 160)
        let randomLong = randomNumber(min: -160.0, max: 160.0)
        let randomLat = randomNumber(min: -75.0, max: 75.0)
        
        // Create three points around circle of random radius r = (0.001, 0.005), which is centered on random center
        let randomRadius = randomNumber(min: 0.001, max: 0.005)
        
        // Calculate random angle offset (0..2pi) which rotates the triangle to construct by random angle
        let randomOffsetAngle = randomNumber(min: 0.0, max: .pi * 2.0)
        
        // Construct three points on circle
        var points: [Coordinate2D] = []
        
        for i in 0...2 {
            let angle: Double = randomOffsetAngle + Double(i) * 2.0 * .pi / 3.0
            let x = randomRadius * cos(angle) + randomLong
            let y = randomRadius * sin(angle) + randomLat
            points.append(Coordinate2D(x: x, y: y))
        }
        
        // Repeat first point as last point
        points.append(points[0])
        
        return (LinearRing(coordinates: points), Coordinate2D(x: randomLong, y: randomLat))
    }
    
    static private func buildRandomGeometries(count: Int) -> [(Geometry, Coordinate2D)] {
        // Build a number of artificial ROIs by random
        var result: [(Geometry, Coordinate2D)] = []
        
        // Build 10000 random ROIs
        for i in 0..<count {
            while true {
                let geometry = buildRandomROI(identifier: "\(i)")
                
                // Once we have the ROI, we need to make sure, it does not overlap with any other ROI
                var createNewRoi = false
                
                for r in result {
                    if boxesOverlap(box1: geometry.0.envelope, box2: r.0.envelope) {
                        // We need to create a new ROI as the current overlaps with another
                        createNewRoi = true
                        break
                    }
                }
                
                if createNewRoi {
                    continue
                }
                
                // At this point we have a non-overlapping geometry
                result.append(geometry)
                
                break   // Bail out of loop
            }
        }
        
        return result
    }
    
    static private func boxesOverlap(box1: (Coordinate2D, Coordinate2D), box2: (Coordinate2D, Coordinate2D)) -> Bool {
        let longOverlap = valueInRange(value: box1.0.x, min: box2.0.x, max: box2.1.x) || valueInRange(value: box2.0.x, min: box1.0.x, max: box1.1.x)
        let latOverlap = valueInRange(value: box1.1.y, min: box2.1.y, max: box2.0.y) || valueInRange(value: box2.0.y, min: box1.1.y, max: box1.0.y)
        return longOverlap && latOverlap
    }
    
    static private func valueInRange(value: Double, min: Double, max: Double) -> Bool {
        return (value >= min) && (value <= max)
    }
}
