//
//  File.swift
//  
//
//  Created by Eric Bodnick on 10/24/22.
//

import Foundation
import Collections

extension NSCountedSet {
    func union(_ otherSet: NSCountedSet) -> NSCountedSet {
        let copy = self.copy() as! NSCountedSet
        copy.union(otherSet as Set)
        return copy
    }
    
    func intersection(_ otherSet: NSCountedSet) -> NSCountedSet {
        let copy = self.copy() as! NSCountedSet
        copy.intersect(otherSet as Set)
        return copy
    }
    
    func subtraction(_ otherSet: NSCountedSet) -> NSCountedSet {
        let copy = self.copy() as! NSCountedSet
        copy.minus(otherSet as Set)
        return copy
    }
}

public struct CountedSet<Element: Hashable>: ExpressibleByArrayLiteral, SetAlgebra, RawRepresentable, Sequence {
    public struct Iterator: RawRepresentable, IteratorProtocol {
        public var rawValue: NSEnumerator
        
        public init(rawValue: NSEnumerator) {
            self.rawValue = rawValue
        }
        
        public mutating func next() -> Element? {
            rawValue.nextObject() as? Element
        }
    }
    
    public func makeIterator() -> Iterator {
        Iterator(rawValue: rawValue.objectEnumerator())
    }
    
    public init() {
        self.rawValue = .init()
    }
    
    public func contains(_ member: Element) -> Bool {
        self.rawValue.contains(member)
    }
    
    @discardableResult public mutating func insert(_ newMember: __owned Element) -> (inserted: Bool, memberAfterInsert: Element) {
        rawValue = rawValue.copy() as! RawValue
        
        if rawValue.contains(newMember) {
            return (false, rawValue.first(where: { $0 as! Element == newMember})! as! Element)
        } else {
            rawValue.add(newMember)
            return (true, newMember)
        }
    }
    
    public mutating func remove(_ member: Element) -> Element? {
        rawValue = rawValue.copy() as! RawValue
        
        if rawValue.contains(member) {
            rawValue.remove(member)
            return member
        } else {
            return nil
        }
    }
    
    public mutating func update(with newMember: __owned Element) -> Element? {
        rawValue = rawValue.copy() as! NSCountedSet
        
        if rawValue.contains(newMember) {
            self.rawValue.add(newMember)
            return newMember
        } else {
            self.rawValue.add(newMember)
            return nil
        }
        
        
    }
    
    public init(arrayLiteral values: Element...) {
        self.rawValue = NSCountedSet(array: values)
    }
    
    public init(_ values: [Element]) {
        self.rawValue = NSCountedSet(array: values)
    }
    
    /// Creates a CountedSet from an NSCountedSet. Copies the value. Traps if the element type of the given set doesn't match the element type given.
    /// - Parameter rawValue: The raw value.
    public init(rawValue: NSCountedSet) {
        // Checks if the element types match.
        _ = rawValue.map { $0 as! Element }
        
        self.rawValue = rawValue.copy() as! NSCountedSet
    }
    
    /// Creates a CountedSet from an NSCountedSet. Copies the value. Doesn't check if the element type of the given set doesn't match the element type given.
    /// - Parameter rawValue: The raw value.
    public init(unsafeRawValue: NSCountedSet) {
        self.rawValue = unsafeRawValue.copy() as! NSCountedSet
    }
    
    public func union(_ other: __owned CountedSet<Element>) -> CountedSet<Element> {
        .init(rawValue: rawValue.union(other.rawValue))
    }
    
    public func intersection(_ other: CountedSet<Element>) -> CountedSet<Element> {
        .init(rawValue: rawValue.intersection(other.rawValue))
    }
     
    public func symmetricDifference(_ other: __owned CountedSet<Element>) -> CountedSet<Element> {
        let A = self.rawValue
        let B = other.rawValue
        
        return .init(rawValue: (A.subtraction(B)).union(B.subtraction(A)))
    }
    
    
    public mutating func formUnion(_ other: __owned CountedSet<Element>) {
        self.rawValue = self.rawValue.copy() as! NSCountedSet
        self.rawValue = self.rawValue.union(other.rawValue)
    }
    
    public mutating func formIntersection(_ other: CountedSet<Element>) {
        self.rawValue = self.rawValue.copy() as! NSCountedSet
        self.rawValue = self.rawValue.intersection(other.rawValue)
    }
    
    public mutating func formSymmetricDifference(_ other: __owned CountedSet<Element>) {
        self.rawValue = self.rawValue.copy() as! NSCountedSet
        self = self.symmetricDifference(other)
    }
    
    public typealias ArrayLiteralElement = Element
    public var rawValue: NSCountedSet
    
    public func count(of object: Element) -> Int {
        rawValue.count(for: object)
    }
}

/// The union operator.
infix operator ∪

/// The mutating union operator.
infix operator ∪=

/// The intersection operator.
infix operator ∩

/// The mutating intersection operator.
infix operator ∩=

public extension SetAlgebra {
    /// Creates an intersection of `lhs` and `rhs`.
    static func ∩ (lhs: Self, rhs: Self) -> Self {
        lhs.intersection(rhs)
    }

    /// Sets `lhs` equal to the intersection of `lhs` and `rhs`.
    static func ∩= (lhs: inout Self, rhs: Self) {
        lhs = lhs ∩ rhs
    }
    
    /// Creates a union of `lhs` and `rhs`.
    static func ∪ (lhs: Self, rhs: Self) -> Self {
        lhs.intersection(rhs)
    }
    
    /// Sets `lhs` equal to the union of `lhs` and `rhs`.
    static func ∪= (lhs: inout Self, rhs: Self) {
        lhs = lhs ∪ rhs
    }
}

public typealias OrderedSet = OrderedCollections.OrderedSet
/// A collection that can temporarily store transient key-value pairs that are subject to eviction when resources are low.
///
///


/// Caches use reference semantics.
public struct Cache<Key: Hashable, Value> {
    var rawValue: NSCache<HashableReference<Key>, Reference<Value>>
    internal var delegate: Delegate
    
    public var name: String {
        get { rawValue.name }
        set { rawValue.name = newValue }
    }
    
    public var maxCount: Int {
        get { rawValue.countLimit }
        set { rawValue.countLimit = newValue }
    }
    
    public var maxCost: Int {
        get { rawValue.totalCostLimit }
        set { rawValue.totalCostLimit = newValue }
    }
    
    public var evictsDiscardableContent: Bool {
        get { rawValue.evictsObjectsWithDiscardedContent }
        set { rawValue.evictsObjectsWithDiscardedContent = newValue }
    }
    
    public subscript(key: Key, cost cost: Int) -> Value? {
        get {
            self.rawValue.object(forKey: HashableReference(wrappedValue: key))?.wrappedValue
        }
        set {
            if let newValue {
                rawValue.setObject(Reference(wrappedValue: newValue), forKey: HashableReference(wrappedValue: key), cost: cost)
            } else {
                rawValue.removeObject(forKey: HashableReference(wrappedValue: key))
            }
        }
    }
    
    public subscript(key: Key) -> Value? {
        get {
            self.rawValue.object(forKey: HashableReference(wrappedValue: key))?.wrappedValue
        }
        set {
            if let newValue {
                rawValue.setObject(Reference(wrappedValue: newValue), forKey: HashableReference(wrappedValue: key))
            } else {
                rawValue.removeObject(forKey: HashableReference(wrappedValue: key))
            }
        }
    }
    
    public init() {
        self.rawValue = NSCache<HashableReference<Key>, Reference<Value>>()
        self.delegate = Delegate()
        self.rawValue.delegate = delegate
    }
    
    public mutating func removeAll() {
        self.rawValue.removeAllObjects()
    }
    
    public var onEviction: (Value) -> Void {
        get { delegate.willEvict }
        set { delegate.willEvict = newValue }
    }
    
    class Delegate: NSObject, NSCacheDelegate {
        var willEvict: (Value) -> Void = {_ in}
        
        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
            willEvict((obj as! Reference<Value>).wrappedValue)
        }
    }
}

extension Cache where Value: DiscardableContent {
    public subscript(key: Key, cost cost: Int) -> Value? {
        get {
            self.rawValue.object(forKey: HashableReference(wrappedValue: key))?.wrappedValue
        }
        set {
            if let newValue {
                rawValue.setObject(DiscardableContentReference(wrappedValue: newValue), forKey: HashableReference(wrappedValue: key), cost: cost)
            } else {
                rawValue.removeObject(forKey: HashableReference(wrappedValue: key))
            }
        }
    }
    
    public subscript(key: Key) -> Value? {
        get {
            self.rawValue.object(forKey: HashableReference(wrappedValue: key))?.wrappedValue
        }
        set {
            if let newValue {
                rawValue.setObject(DiscardableContentReference(wrappedValue: newValue), forKey: HashableReference(wrappedValue: key))
            } else {
                rawValue.removeObject(forKey: HashableReference(wrappedValue: key))
            }
        }
    }
}
extension Cache: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init()
        for element in elements {
            self[element.0] = element.1
        }
    }
}

/// A reference to a value.
@propertyWrapper public class Reference<Referenced> {
    public var wrappedValue: Referenced
    
    public init(wrappedValue: Referenced) {
        self.wrappedValue = wrappedValue
    }
}

extension Reference: DiscardableContent where Referenced: DiscardableContent {
    public func beginAccess() -> Bool {
        wrappedValue.beginAccess()
    }
    
    public func endAccess() {
        wrappedValue.endAccess()
    }
    
    public func discard() {
        wrappedValue.discard()
    }
    
    public var isDiscarded: Bool {
        wrappedValue.isDiscarded
    }
}

extension Reference: Equatable where Referenced: Equatable {
    public static func == (lhs: Reference<Referenced>, rhs: Reference<Referenced>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Reference: Hashable where Referenced: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}

@propertyWrapper internal final class HashableReference<Referenced: Hashable>: NSObject {
    var wrappedValue: Referenced
    
    init(wrappedValue: Referenced) {
        self.wrappedValue = wrappedValue
    }
    
    @objc override var hash: Int {
        print("Hash value of \(self) is \(wrappedValue.hashValue)")
        return wrappedValue.hashValue
    }
    
    @objc override func isEqual(_ object: Any?) -> Bool {
        if (object as? HashableReference<Referenced>).map({ $0.wrappedValue == self.wrappedValue }) ?? false {
            print("\(self) == \(object ?? "")")
            return true
        } else {
            print("\(self) != \(object ?? "")")
            return false
        }
    }
}

internal class DiscardableContentReference<Referenced>: Reference<Referenced>, NSDiscardableContent where Referenced: DiscardableContent {
    public func beginContentAccess() -> Bool {
        wrappedValue.beginAccess()
    }
    
    public func endContentAccess() {
        wrappedValue.endAccess()
    }
    
    public func discardContentIfPossible() {
        wrappedValue.discard()
    }
    
    public func isContentDiscarded() -> Bool {
        wrappedValue.isDiscarded
    }
}

public protocol DiscardableContent {
    /// Tries to begin access and returns whether it's been successful.
    func beginAccess() -> Bool
    
    /// Ends the access to the content.
    func endAccess()
    
    /// Discards the contents if the value of the accessed counter is zero.
    func discard()
    
    /// Whether `self` has been discarded.
    var isDiscarded: Bool { get }
}

extension DiscardableContent where Self: RawRepresentable, Self.RawValue: NSPurgeableData {
    public func beginAccess() -> Bool { rawValue.beginContentAccess() }
    public func endAccess() { rawValue.endContentAccess() }
    public func discard() { rawValue.discardContentIfPossible() }
    public var isDiscarded: Bool { rawValue.isContentDiscarded() }
}

public struct PurgeableData: DiscardableContent, MutableDataProtocol, RawRepresentable {
    public var rawValue: NSPurgeableData
    
    public init(rawValue: NSPurgeableData) {
        self.rawValue = rawValue
    }
    
    public var startIndex: Int { rawValue.startIndex }
    public var endIndex: Int { rawValue.endIndex }
    
    public subscript(position: Int) -> UInt8 {
        get { rawValue[position] }
        set {
            var data = Data(rawValue)
            data[position] = newValue
            rawValue = NSPurgeableData(data: data)
        }
    }
    
    public func index(after i: Int) -> Int {
        i + 1
    }
    
    public func index(before i: Int) -> Int {
        i - 1
    }
    
    public typealias Regions = RawValue.Regions
    public var regions: Regions { rawValue.regions }
    
    public func copyBytes<DestinationType>(to: UnsafeMutableBufferPointer<DestinationType>, count: Int) -> Int {
        rawValue.copyBytes(to: to, count: count)
    }
    
    public func copyBytes<DestinationType, R>(to: UnsafeMutableBufferPointer<DestinationType>, from: R) -> Int where R : RangeExpression, Int == R.Bound {
        rawValue.copyBytes(to: to, from: from)
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, UInt8 == C.Element {
        var data = Data(rawValue)
        data.replaceSubrange(subrange, with: newElements)
        rawValue = NSPurgeableData(data: data)
    }
    
    public init() {
        self.rawValue = RawValue(data: Data())
    }
    
    public mutating func resetBytes<R>(in range: R) where R : RangeExpression, Int == R.Bound {
        rawValue.resetBytes(in: NSRange(range))
    }
}

extension CountedSet: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.allObjects.map { $0 as! Element } == rhs.rawValue.allObjects.map { $0 as! Element }
    }
}

extension CountedSet: CustomStringConvertible {
    public var description: String {
        rawValue.allObjects.description
    }
}

extension PurgeableData: CustomStringConvertible {
    public var description: String {
        (rawValue as Data).description
    }
}


