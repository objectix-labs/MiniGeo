//
//  QuadTree.swift
//  MiniGeo
//
//  Created by Christian Rühl on 17.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

public class QuadTree {
    
    // The current depth of this tree
    public private(set) var depth: Int = 0
    
    // The number of nodes in this tree
    public private(set) var nodeCount: Int = 0

    // Contains the root node of the tree (if set)
    private var root: QuadTreeNode?
    
    // (Re-)builds the quad tree from the specified ROIs
    public func build(from geometries: Set<Geometry>) {
        depth = 0
        nodeCount = 1
        
        // Optimization: to save a few levels in tree, we limit the Quadtree to the bounding box of the specified ROIs.
        var minLat: Double = 1000.0
        var minLong: Double = 1000.0
        var maxLat: Double = -1000.0
        var maxLong: Double = -1000.0
        
        for roi in geometries {
            let boundingBox = roi.envelope
            if boundingBox.0.x < minLong {
                minLong = boundingBox.0.x
            }
            
            if boundingBox.1.y < minLat {
                minLat = boundingBox.1.y
            }
            
            if boundingBox.1.x > maxLong {
                maxLong = boundingBox.1.x
            }
            
            if boundingBox.0.y > maxLat {
                maxLat = boundingBox.0.y
            }
        }
        
        // Recursively build tree structure, starting with the bounding box we just calculated from ROI data
        let worldGeometry = QuadGeometry(topLeft: Coordinate2D(x: minLong, y: maxLat),
                                         topRight: Coordinate2D(x: maxLong, y: maxLat),
                                         bottomRight: Coordinate2D(x: maxLong, y: minLat),
                                         bottomLeft: Coordinate2D(x: minLong, y: minLat))
        self.root = QuadTreeNode(quad: worldGeometry)
        
        // Kick off recursion
        quadStep(node: self.root!, relevantROIs: geometries, depth: 1)
        
        // Print some tree statistics
        debugPrint("Quadtree contains \(nodeCount) nodes distributed over \(depth) levels.")
        debugPrint("Bounding Box of Quadtree is (\(minLong), \(minLat), \(maxLong), \(maxLat))")
    }
    
    // Delivers the ROIs for the specified coordinate (or an empty set, if no ROIs were present)
    public func fetch(for coordinate: Coordinate2D) -> Set<Geometry> {
        if root == nil {
            // Quad tree not built yet -> no ROIs can be found
            return Set<Geometry>()
        }
        
        // Start search from root node and perform directed search to reach leaf node that contains the specified location.
        if let result = searchStep(quad: self.root!, location: coordinate) {
            // We found the quad tree leaf node, that contains the coordinate. Return the ROIs attached to that node as result
            return result.geometries ?? Set<Geometry>()
        } else {
            // We were not able to find a quad tree node that contains the location. In that case, we return an empty result.
            return Set<Geometry>()
        }
    }
    
    // AUX functions
    
    // Processes a single quad tree node by dividing the quad into four subquads, recursively callinf itself with each new node, or terminating recursion if the
    // specified quad tree node did not contain at least one ROI
    private func quadStep(node: QuadTreeNode, relevantROIs: Set<Geometry>, depth: Int) {
        if depth > self.depth {
            self.depth = depth
        }
        
        // We first check, what ROIs (from the relevant ones) are contained in this quad.
        var containedROIs: Set<Geometry> = Set<Geometry>()
        
        for roi in relevantROIs {
            if quadOverlaps(quad: node.quad, roi: roi) {
                containedROIs.insert(roi)
            }
        }
        
        // RECURSION TERMINATION CHECKS
        
        // If we did not find a contained ROI, we can terminate recursion here
        if containedROIs.isEmpty {
            node.geometries = Set<Geometry>() // Current node becomes leaf node with no ROIs
            node.childNodes = nil
            return  // End of recursion
        }
        
        // Special case: if the current quad contains only one ROI, we do not need to further refine that quad, as a further refinement would not result into smaller partitions of
        // ROIs anyways.
        if containedROIs.count == 1 {
            node.geometries = containedROIs
            node.childNodes = nil
            return  // End of recursion
        }
        
        // We check if the current node's geometry is smaller than the minimum allowed quadsize. If this is the case, we terminate recursion here
        // and save the contained ROIs (if any)
        let dlat = node.quad.bottomRight.y - node.quad.topLeft.y
        let dlong = node.quad.bottomRight.x - node.quad.topLeft.x
        
        // Depending on latitude, the set logitude threshold equals to a range of 50 and 100 meters (cf. https://en.wikipedia.org/wiki/Geographic_coordinate_system), while the
        // latitude threshold equals to roughly 112 meters
        if fabs(dlat) < 0.001 || fabs(dlong) < 0.001 {
            node.geometries = containedROIs
            node.childNodes = nil
            return
        }
        
        // RECURSION STEP
        
        // Otherwise, we enter next recursion level and split the quad into four subquads...
        let centerCoordinate = Coordinate2D(x: dlong / 2.0 + node.quad.topLeft.x,
                                            y: dlat / 2.0 + node.quad.topLeft.y)
        
        let centerTop = Coordinate2D(x: centerCoordinate.x, y: node.quad.topLeft.y)
        let centerBottom = Coordinate2D(x: centerCoordinate.x, y: node.quad.bottomRight.y)
        let centerLeft = Coordinate2D(x: node.quad.topLeft.x, y: centerCoordinate.y)
        let centerRight = Coordinate2D(x: node.quad.bottomRight.x, y: centerCoordinate.y)
        
        let quadGeometry1: QuadGeometry = QuadGeometry(topLeft: node.quad.topLeft, topRight: centerTop, bottomRight: centerCoordinate, bottomLeft: centerLeft)
        let quadGeometry2: QuadGeometry = QuadGeometry(topLeft: centerTop, topRight: node.quad.topRight, bottomRight: centerRight, bottomLeft: centerCoordinate)
        let quadGeometry3: QuadGeometry = QuadGeometry(topLeft: centerCoordinate, topRight: centerRight, bottomRight: node.quad.bottomRight, bottomLeft: centerBottom)
        let quadGeometry4: QuadGeometry = QuadGeometry(topLeft: centerLeft, topRight: centerCoordinate, bottomRight: centerBottom, bottomLeft: node.quad.bottomLeft)
        
        let node1: QuadTreeNode = QuadTreeNode(quad: quadGeometry1)
        let node2: QuadTreeNode = QuadTreeNode(quad: quadGeometry2)
        let node3: QuadTreeNode = QuadTreeNode(quad: quadGeometry3)
        let node4: QuadTreeNode = QuadTreeNode(quad: quadGeometry4)
        
        node.childNodes = (node1, node2, node3, node4)
        
        // Step down in recursion
        quadStep(node: node1, relevantROIs: containedROIs, depth: depth+1)
        quadStep(node: node2, relevantROIs: containedROIs, depth: depth+1)
        quadStep(node: node3, relevantROIs: containedROIs, depth: depth+1)
        quadStep(node: node4, relevantROIs: containedROIs, depth: depth+1)
        
        nodeCount += 4
    }
    
    // Performs a recursive directed search on the specified node. Returns the quad tree leaf node that contains the location
    private func searchStep(quad: QuadTreeNode, location: Coordinate2D) -> QuadTreeNode? {
        // Is the coordinate contained in the current tree node? If not, we terminate recursion here
        if !quadContains(quad: quad.quad, location: location) {
            return nil
        }
        
        // Current quad contains location, so we need to enter next recursion level in case this node is not a leaf node, ie. has child nodes
        
        // Check, which child node contains the location and perform search step on that node
        if let childs = quad.childNodes {
            if let node = searchStep(quad: childs.0, location: location) {
                return node
            }
            
            if let node = searchStep(quad: childs.1, location: location) {
                return node
            }

            if let node = searchStep(quad: childs.2, location: location) {
                return node
            }

            if let node = searchStep(quad: childs.3, location: location) {
                return node
            }
            
            // At this point, we did not find any matching child node. This should never happen. If it does, we are fucked.
            return nil
        } else {
            // Is a leaf node, so we are done searching
            return quad
        }
    }
    
    // Checks, if the specified quad geometry intersects with the given ROI. For sake of performance, we use a simple bounding-box test. This
    // might result in ROIs that are incorrectly identified as "contained". This does not compromise accuracy of this quad tree but result in a slightly
    // less inefficient quad tree. We might later replace this test with a more accurate one, if performance is not an issue.
    private func quadOverlaps(quad: QuadGeometry, roi: Geometry) -> Bool {
        let roiBbox = roi.envelope
        /*
        cf. https://stackoverflow.com/questions/306316/determine-if-two-rectangles-overlap-each-other
         
        bool valueInRange(int value, int min, int max)
        { return (value >= min) && (value <= max); }
        
        bool rectOverlap(rect A, rect B)
        {
            bool xOverlap = valueInRange(A.x, B.x, B.x + B.width) ||
                valueInRange(B.x, A.x, A.x + A.width);
         
            bool yOverlap = valueInRange(A.y, B.y, B.y + B.height) ||
                valueInRange(B.y, A.y, A.y + A.height);
         
            return xOverlap && yOverlap;
        }*/
        let longOverlap = valueInRange(value: quad.topLeft.x , min: roiBbox.0.x, max: roiBbox.1.x) || valueInRange(value: roiBbox.0.x, min: quad.topLeft.x, max: quad.bottomRight.x)
        let latOverlap = valueInRange(value: quad.topLeft.y, min: roiBbox.1.y, max: roiBbox.0.y) || valueInRange(value: roiBbox.0.y, min: quad.bottomRight.y, max: quad.topLeft.y)
        
        return longOverlap && latOverlap
    }
    
    // Checks, if the specified coordinate is within a quad geometry.
    private func quadContains(quad: QuadGeometry, location: Coordinate2D) -> Bool {
        return location.y <= quad.topLeft.y &&
            location.y > quad.bottomRight.y &&
            location.x < quad.bottomRight.x &&
            location.x >= quad.topLeft.x
    }
    
    private func valueInRange(value: Double, min: Double, max: Double) -> Bool {
        return (value >= min) && (value <= max)
    }
}

fileprivate class QuadTreeNode {
    init(quad: QuadGeometry) {
        self.quad = quad
    }
    
    // The geometry of the quad represented by this node
    var quad: QuadGeometry
    
    // The region of interests stored for this quad. For sake of memory efficiency, only leaf nodes have this member set properly.
    var geometries: Set<Geometry>?
    
    // The four child nodes of this node (if available). Leaf nodes do not have this member set.
    var childNodes: (QuadTreeNode, QuadTreeNode, QuadTreeNode, QuadTreeNode)?
}

// Implements the geometrical structure of a single quad
fileprivate struct QuadGeometry {
    var topLeft: Coordinate2D
    var topRight: Coordinate2D
    var bottomRight: Coordinate2D
    var bottomLeft: Coordinate2D
}
