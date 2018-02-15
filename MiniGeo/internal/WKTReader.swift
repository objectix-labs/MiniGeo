//
//  WKTReader.swift
//  MiniGeo
//
//  Created by Christian Rühl on 15.02.18.
//  Copyright © 2018 Objectix Software Solutions GmbH. All rights reserved.
//

import Foundation

internal class WKTReader {
    
    public let supportedWktTypes: Set<String> = ["POLYGON", "MULTIPOLYGON"]
    
    public func parse(wktString: String) -> Geometry? {
        // We match the string against any supported WKT type
        for supportedType in supportedWktTypes {
            let pattern = String(format: "%@[ ]*(\\(.*\\))", supportedType)
            let groups = self.matchGroups(string: wktString, by: pattern)
            
            // If we need to have matched at least one groups, or we are not dealing with the assumed type.
            if groups.isEmpty {
                continue
            }
            
            // Otherwise, we have found a supported type
            if let matchedData: String = groups.first {
                // Matched the given type in first group.
                if supportedType == "POLYGON" {
                    return parsePolygon(wktInput: matchedData)
                } else if supportedType == "MULTIPOLYGON" {
                    return parseMultiPolygon(wktInput: matchedData)
                } else {
                    // WKT string contains invalid or unsupported type
                    return nil
                }
            }
        }
        
        // At this point, we have not found a supported WKT type.
        return nil
    }
    
    // Parses the data structure of a POLYGON element: "(coordinate_sequence1, coordinate_sequence2, ...)"
    public func parsePolygon(wktInput: String) -> Polygon? {
        var result: [[Coordinate2D]] = []
        let input = wktInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Make sure, string is enclosed in a pair of parentheses
        let groups = matchGroups(string: input, by: "^\\((.*)\\)$")
        
        guard let polygon: String = groups.first else {
            // Invalid Polygon
            return nil
        }
        
        // Polygon string is made of a sequence of coordinate sequences
        // Otherwise, we split the found group by ,
        let coordinateSequences: [String] = matchGroups(string: polygon, by: "(\\(.*\\))[,]?[ ]*")
        
        // If we have not matched at least one group, we deal with an empty polygon
        if coordinateSequences.isEmpty {
            return Polygon(exteriorRing: nil, interiorRings: nil)
        }
        
        // Iterate through coordinate sequences
        for coordinateSequence in coordinateSequences {
            if let seq = parseCoordinateSequence(wktInput: coordinateSequence) {
                result.append(seq)
            } else {
                // Invalid sequence detected!
                return nil;
            }
        }
        
        // We now construct a Polygon geometry from the collected coordinate sequences.
        
        // The first detected coordinate sequence becomes the Polygon's exterior ring. Any following
        // coordinate sequende is made an interior ring.
        var exteriorRing: LinearRing?
        var interiorRings: [LinearRing]?
        
        if result.count > 0 {
            exteriorRing = LinearRing(coordinates: result.removeFirst())
        }
        
        if result.count > 0 {
            interiorRings = [];
            
            for ring in result {
                interiorRings!.append(LinearRing(coordinates: ring))
            }
        }
        
        return Polygon(exteriorRing: exteriorRing, interiorRings: interiorRings)
    }
    
    public func parseMultiPolygon(wktInput: String) -> MultiPolygon? {
        return nil
    }
    
    // "x y"
    public func parseCoordinatePair(wktInput: String) -> Coordinate2D? {
        // Split string by any number of spaces in between
        let tokens = split(string: wktInput, by: "[ ]+")
        
        if tokens.count != 2 {
            // Invalid coordinate pair!
            return nil;
        }
        
        if let x = Double(tokens[0]), let y = Double(tokens[1]) {
            return Coordinate2D(x: x, y: y)
        } else {
            // Invalid coordinate value specified
            return nil
        }
    }
    
    // "(coordinate1, coordinate2, ...)"
    public func parseCoordinateSequence(wktInput input: String) -> [Coordinate2D]? {
        var result: [Coordinate2D] = []

        let input = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Make sure, string is enclosed in a pair of parentheses
        let groups = matchGroups(string: input, by: "^\\((.*)\\)$")
        
        guard let sequence: String = groups.first else {
            // Invalid sequence
            return nil
        }
        
        // Otherwise, we match the coordinate tuples, separated by commata
        let coordinatePairs: [String] = matchGroups(string: sequence, by: "([-+]?[0-9]*\\.?[0-9]+[ ]*[-+]?[0-9]*\\.?[0-9]+),?[ ]*")
        
        // If we have only extracted not at least one group, we deal with an empty sequence
        if coordinatePairs.isEmpty {
            return result
        }
        
        for coordinatePair in coordinatePairs {
            // Attempt to parse each pair string
            if let cp: Coordinate2D = parseCoordinatePair(wktInput: coordinatePair) {
                // Valid coordinate pair -> add to result
                result.append(cp)
            } else {
                // Found invalid coordinate pair -> so the whole sequence is invalid
                return nil
            }
        }
        
        return result
    }
    
    // Helper: Splits string by regular expression
    public func split(string input: String, by regularExpression: String) -> [String] {
        let input = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex: NSRegularExpression = try! NSRegularExpression(pattern: regularExpression, options: [])
        let preparedString: String = regex.stringByReplacingMatches(in: input,
                                                                    range: NSMakeRange(0, input.count),
                                                                    withTemplate: "|")
        return preparedString.components(separatedBy: "|")
    }
    
    // Helper: match a string format by regular expression and return the matching components
    public func match(string input: String, by regularExpression: String) -> [String] {
        let regex: NSRegularExpression = try! NSRegularExpression(pattern: regularExpression)
        let matches = regex.matches(in: input, range: NSMakeRange(0, input.count))
        return matches.map {
            String(input[Range($0.range, in: input)!])
        }
    }
    
    // Helper to fetch the matching groups.
    public func matchGroups(string input: String, by regularExpression: String) -> [String] {
        var results = [String]()
        
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: regularExpression, options: [])
        } catch {
            return results
        }
        
        let matches = regex.matches(in: input, options: [], range: NSRange(location:0, length: input.count))
        
        for match in matches {
            let lastRangeIndex = match.numberOfRanges - 1
            guard lastRangeIndex >= 1 else { return results }
            
            for i in 1...lastRangeIndex {
                let capturedGroupIndex = match.range(at: i)
                let matchedString = (input as NSString).substring(with: capturedGroupIndex)
                results.append(matchedString)
            }
        }
        
        return results
    }
}
