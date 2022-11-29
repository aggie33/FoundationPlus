//
//  File.swift
//  
//
//  Created by Eric Bodnick on 10/17/22.
//

import Foundation
import Darwin

/// A 64-bit integer.
public typealias Int = Swift.Int

/// A double-precision floating-point number.
public typealias Double = Swift.Double

/// A structure representing a base-10 number.
public typealias Decimal = Foundation.Decimal

/// Binary data.
public typealias Data = Foundation.Data

/// Binary data.
public typealias DataProtocol = Foundation.DataProtocol

/// Mutable data.
public typealias MutableDataProtocol = Foundation.MutableDataProtocol

/// A type that has underlying contiguous bytes.
public typealias ContiguousBytes = Foundation.ContiguousBytes

/// A pointer to a file or resource on the web.
public typealias URL = Foundation.URL

/// A universally unique identifier.
public typealias UUID = Foundation.UUID

extension URL: ExpressibleByStringLiteral {
    /// Creates a url from a string literal. Traps if the literal isn't valid.
    public init(stringLiteral value: StaticString) {
        self.init(string: value.description)!
    }
    
    /// The components of a URL.
    public typealias Components = Foundation.URLComponents
    
    /// A query item of a URL.
    public typealias QueryItem = Foundation.URLQueryItem
    
    /// Creates a URL from its components.
    /// - Parameters:
    ///   - fragment: The fragment.
    ///   - host: The host.
    ///   - password: The password.
    ///   - path: The path.
    ///   - port: The port.
    ///   - query: The query.
    ///   - queryItems: The query items.
    ///   - scheme: The scheme.
    ///   - user: The user.
    public init?(
        fragment: String? = nil,
        host: String? = nil,
        password: String? = nil,
        path: String,
        port: Int? = nil,
        query: String? = nil,
        queryItems: [URL.QueryItem]? = nil,
        scheme: String? = nil,
        user: String? = nil
    ) {
        if let url = URLComponents(
            fragment: fragment,
            host: host,
            password: password,
            path: path,
            port: port,
            query: query,
            queryItems: queryItems,
            scheme: scheme,
            user: user
        ).url {
            self = url
        } else {
            return nil
        }
    }
    
    /// Creates a URL from components.
    public init?(_ components: Components) {
        if let url = components.url {
            self = url
        } else {
            return nil
        }
    }
}

public typealias URLComponents = URL.Components
public typealias URLQueryItem = URL.QueryItem

extension URL.Components {
    /// Creates URL components from a URL.
    /// - Parameters:
    ///   - url: The url.
    ///   - resolvesAgainstBase: Whether to resolve against the url's base URL.
    init?(_ url: URL, resolvesAgainstBase: Bool = true) {
        self.init(url: url, resolvingAgainstBaseURL: resolvesAgainstBase)
    }
    
    /// Creates URLComponents from its components.
    public init(
        fragment: String? = nil,
        host: String? = nil,
        password: String? = nil,
        path: String = "",
        port: Int? = nil,
        query: String? = nil,
        queryItems: [URL.QueryItem]? = nil,
        scheme: String? = nil,
        user: String? = nil
    ) {
        self.init()
        self.fragment = fragment
        self.host = host
        self.password = password
        self.path = path
        self.port = port
        self.query = query
        self.queryItems = queryItems
        self.scheme = scheme
        self.user = user
    }
}

/// A point.
public typealias Point = NSPoint
extension Point: Hashable, Codable {
    public enum CodingKeys: CodingKey {
        case x
        case y
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(x: try container.decode(CGFloat.self, forKey: .x),
                  y: try container.decode(CGFloat.self, forKey: .y))
    }
    
    public static func == (lhs: CGPoint, rhs: CGPoint) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

/// A size.
public typealias Size = NSSize
extension Size: Hashable, Codable {
    public enum CodingKeys: CodingKey {
        case width
        case height
    }
    
    public static func == (lhs: CGSize, rhs: CGSize) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let width = try container.decode(CGFloat.self, forKey: .width)
        let height = try container.decode(CGFloat.self, forKey: .height)
        self.init(width: width, height: height)
    }
}

/// A 2D rectangle.
public typealias Rect = NSRect
extension Rect: Hashable, Codable {
    public enum CodingKeys: CodingKey {
        case origin
        case size
    }
    
    public static func == (lhs: CGRect, rhs: CGRect) -> Bool {
        lhs.origin == rhs.origin && rhs.size == lhs.size
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin)
        hasher.combine(size)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(origin, forKey: .origin)
        try container.encode(size, forKey: .size)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            origin: try container.decode(Point.self, forKey: .origin),
            size: try container.decode(Size.self, forKey: .size)
        )
    }
}

/// A directional vector.
public typealias Vector = CGVector
extension Vector: Hashable, Codable {
    public enum CodingKeys: CodingKey {
        case dx
        case dy
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dx, forKey: .dx)
        try container.encode(dy, forKey: .dy)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dx = try container.decode(CGFloat.self, forKey: .dx)
        let dy = try container.decode(CGFloat.self, forKey: .dy)
        self.init(dx: dx, dy: dy)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(dx)
        hasher.combine(dy)
    }
}

/// A graphics transformation.
public typealias AffineTransform = Foundation.AffineTransform

extension AffineTransform {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(m22)
        hasher.combine(m21)
        hasher.combine(m12)
        hasher.combine(m11)
        hasher.combine(tX)
        hasher.combine(tY)
    }
}

extension AffineTransform {
    public static func rotation(by angle: Measurement<Angle>) -> Self {
        Self(rotationByDegrees: angle.degrees)
    }
    
    public static func scale(by scale: Scale) -> Self {
        Self(scaleByX: scale.sx, byY: scale.sy)
    }
    
    public static func translation(by vector: Vector) -> Self {
        Self(translationByX: vector.dx, byY: vector.dy)
    }
    
    public mutating func rotate(by angle: Measurement<Angle>) {
        self.rotate(byDegrees: angle.degrees)
    }
    
    public mutating func scale(by scale: Scale) {
        self.scale(x: scale.sx, y: scale.sy)
    }
    
    public mutating func translate(by vector: Vector) {
        self.translate(x: vector.dx, y: vector.dy)
    }
}

/// A scale relative to an original size.
public struct Scale: Equatable, Hashable, Codable {
    /// The x-scale.
    public var sx: Double
    
    /// The y-scale.
    public var sy: Double
}


extension Scale {
    /// Creates a scale with equal x and y scales.
    public init(_ scale: Double) {
        self.init(sx: scale, sy: scale)
    }
}

extension Vector: AdditiveArithmetic {
    public static func == (lhs: CGVector, rhs: CGVector) -> Bool {
        lhs.dx == rhs.dx && lhs.dy == rhs.dy
    }
    
    public static var zero: CGVector {
        CGVector()
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }
    
    public static func * (lhs: Self, rhs: Double) -> Self {
        Self(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
    }
}

extension Point {
    public static func + (lhs: Point, rhs: Vector) -> Point {
        Point(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
    }
    
    public static func - (lhs: Point, rhs: Vector) -> Point {
        Point(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
    }
    
    public static func += (lhs: inout Point, rhs: Vector) {
        lhs = lhs + rhs
    }
    
    public static func -= (lhs: inout Point, rhs: Vector) {
        lhs = lhs - rhs
    }
    
    public func applying(_ transform: AffineTransform) -> Point {
        transform.transform(self)
    }
}

extension Vector {
    public func dotProduct(with other: Vector) -> Double {
        other.dx * self.dx + other.dy * self.dy
    }
    
    public static func * (lhs: Self, rhs: Self) -> Double {
        lhs.dotProduct(with: rhs)
    }
    
    public var magnitude: Double {
        sqrt(dx * dx + dy * dy)
    }
    
    public var angle: Measurement<Angle> {
        .radians(acos(dx / magnitude))
    }
}

/// Measures the y of the point of an angle on a unit circle.
public func sin(_ angle: Measurement<Angle>) -> Double {
    Darwin.sin(angle.radians)
}

/// Measures the x the point of an angle on a unit circle.
public func cos(_ angle: Measurement<Angle>) -> Double {
    Darwin.cos(angle.radians)
}

/// Measures the slope of the tangent line of the point of an angle on a unit circle.
public func tan(_ angle: Measurement<Angle>) -> Double {
    Darwin.tan(angle.radians)
}

/// Makes a signed value positive.
@propertyWrapper public struct Positive<T: SignedInteger> {
    var _wrappedValue: T
    var mode: Mode
    
    public enum Mode {
        case clamping
        case absoluteValue
    }
    
    public init(wrappedValue: T, _ mode: Mode = .clamping) {
        self._wrappedValue = mode == .clamping ? max(0, wrappedValue) : abs(wrappedValue)
        self.mode = mode
    }
    
    public var wrappedValue: T {
        get { _wrappedValue }
        set { _wrappedValue = mode == .clamping ? max(0, newValue) : abs(newValue) }
    }
}

/// Rounds a floating-point value.
@propertyWrapper public struct Rounded<T: BinaryFloatingPoint> {
    var _wrappedValue: T
    var mode: FloatingPointRoundingRule
    
    public init(wrappedValue: T, _ mode: FloatingPointRoundingRule) {
        self._wrappedValue = wrappedValue.rounded(mode)
        self.mode = mode
    }
    
    public var wrappedValue: T {
        get { _wrappedValue }
        set { _wrappedValue = newValue.rounded(mode) }
    }
    
    @Transformed(.identity) var x = Point(x: 0, y: 0)
}

/// Transforms a point by an affine transform.
@propertyWrapper public struct Transformed {
    var _wrappedValue: Point
    var transform: AffineTransform
    
    public var wrappedValue: Point {
        get { _wrappedValue }
        set { _wrappedValue = transform.transform(newValue) }
    }
    
    public init(wrappedValue: Point, _ transform: AffineTransform) {
        self._wrappedValue = transform.transform(wrappedValue)
        self.transform = transform
    }
}

