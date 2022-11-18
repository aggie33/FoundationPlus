//
//  File.swift
//  
//
//  Created by Eric Bodnick on 10/19/22.
//


import Foundation

public typealias String = Swift.String

@available(macOS 12.0, *)
public typealias AttributedString = Foundation.AttributedString

@available(macOS 12.0, *)
public typealias AttributedSubstring = Foundation.AttributedSubstring

@available(macOS 12.0, *)
public typealias AttributedStringProtocol = Foundation.AttributedStringProtocol

public typealias CharacterSet = Foundation.CharacterSet

extension Character {
    public typealias Set = CharacterSet
}

extension Unicode {
    public typealias CharacterSet = Foundation.CharacterSet
}

/// A Scanner scans a string for various objects in string form.
public struct Scanner: RawRepresentable, Equatable, Hashable {
    public var rawValue: Foundation.Scanner
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    private mutating func mutate() {
        rawValue = rawValue.copy() as! RawValue
    }
    
    /// Creates a scanner to scan `string`.
    public init(scanning string: String) {
        self.rawValue = .init(string: string)
    }
    
    /// The string for the scanner to scan.
    public var string: String {
        rawValue.string
    }
    
    /// The index of the string where the scanner will begin scanning.
    public var scanLocation: String.Index {
        get {
            string.index(string.startIndex, offsetBy: rawValue.scanLocation)
        } set {
            mutate(); rawValue.scanLocation = newValue.utf16Offset(in: string)
        }
    }
    
    /// Whether the scanner is case-sensitive.
    public var isCaseSensitive: Bool {
        get { rawValue.caseSensitive }
        set { mutate(); rawValue.caseSensitive = newValue }
    }
    
    /// Characters to ignore while scanning.
    public var ignoredCharacters: Unicode.CharacterSet? {
        get { rawValue.charactersToBeSkipped }
        set { mutate(); rawValue.charactersToBeSkipped = newValue }
    }
    
    /// The locale to use when scanning.
    public var locale: Locale? {
        get { rawValue.locale as? Locale }
        set { mutate(); rawValue.locale = newValue }
    }
    
    /// Scans until it finds a character not contained in `characters` and outputs the result.
    @available(macOS 10.15, *)
    public func scan(while characters: CharacterSet) -> String? {
        return rawValue.scanCharacters(from: characters)
    }
    
    /// Scans until it finds a character contained in `characters` and outputs the result.
    @available(macOS 10.15, *)
    public func scan(until characters: CharacterSet) -> String? {
        return rawValue.scanUpToCharacters(from: characters)
    }
    
    /// Scans for a substring and returns whether or not it was found.
    @available(macOS 10.15, *)
    public func scan(for string: String) -> Bool {
        return rawValue.scanString(string) == nil ? false : true
    }
    
    /// Scans until a given substring is encountered, returning the result.
    @available(macOS 10.15, *)
    public func scan(until string: String) -> String? {
        return rawValue.scanUpToString(string)
    }
    
    /// Scans for an instance of T. Note that the scanner starts scanning where it is, so if the instance is not the first word, the scanner won't catch it.
    /// To fix this, just set the scanner's start location to where the instance is.
    ///```swift
    /// let string = "Happy 1st Birthday!"
    /// let index = string.firstIndex(of: "1")!
    ///
    /// var scanner = Scanner(scanning: string)
    /// scanner.scanLocation = index
    /// print(scanner.scan(for: Int.self)
    /// // prints "1"
    /// ```
    public func scan<T: Scannable>(for type: T.Type, representation: T.Representation) -> T? {
        T(scanning: self, representation: representation)
    }
    
    public func scan<T: Scannable>(for type: T.Type) -> T? where T.Representation == Void {
        T(scanning: self)
    }
    
    @available(macOS 10.15, *)
    public func scan<T: Scannable>(for type: T.Type, representation: NumberRepresentation = .decimal) -> T? where T.Representation == NumberRepresentation {
        T(scanning: self, representation: representation)
    }
    
    public var hasReachedEnd: Bool { rawValue.isAtEnd }
    
    @available(macOS 10.15, *)
    public var currentIndex: String.Index { rawValue.currentIndex }
    
    @available(macOS 10.15, *)
    public typealias NumberRepresentation = Foundation.Scanner.NumberRepresentation
}


public protocol Scannable {
    associatedtype Representation
    init?(scanning scanner: Scanner, representation: Representation)
}

public extension Scannable where Representation == Void {
    init?(scanning scanner: Scanner) {
        self.init(scanning: scanner, representation: ())
    }
}

@available(macOS 10.15, *)
extension Decimal: Scannable {
    public init?(scanning scanner: Scanner, representation: Void) {
        if let decimal = scanner.rawValue.scanDecimal() {
            self = decimal
        } else {
            return nil
        }
    }
}

@available(macOS 10.15, *)
extension Double: Scannable {
    public init?(scanning scanner: Scanner, representation: Scanner.NumberRepresentation) {
        if let decimal = scanner.rawValue.scanDouble(representation: representation) {
            self = decimal
        } else {
            return nil
        }
    }
}

@available(macOS 10.15, *)
extension Int64: Scannable {
    public init?(scanning scanner: Scanner, representation: Scanner.NumberRepresentation) {
        if let decimal = scanner.rawValue.scanInt64(representation: representation) {
            self = decimal
        } else {
            return nil
        }
    }
}

@available(macOS 10.15, *)
extension Int32: Scannable {
    public init?(scanning scanner: Scanner, representation: Scanner.NumberRepresentation) {
        if let decimal = scanner.rawValue.scanInt32(representation: representation) {
            self = decimal
        } else {
            return nil
        }
    }
}

@available(macOS 10.15, *)
extension Int: Scannable {
    public init?(scanning scanner: Scanner, representation: Scanner.NumberRepresentation) {
        if let decimal = scanner.rawValue.scanInt(representation: representation) {
            self = decimal
        } else {
            return nil
        }
    }
}

@available(macOS 10.15, *)
extension UInt64: Scannable {
    public init?(scanning scanner: Scanner, representation: Scanner.NumberRepresentation) {
        if let decimal = scanner.rawValue.scanUInt64(representation: representation) {
            self = decimal
        } else {
            return nil
        }
    }
}

@available(macOS 10.15, *)
extension Float: Scannable {
    public init?(scanning scanner: Scanner, representation: Scanner.NumberRepresentation) {
        if let decimal = scanner.rawValue.scanFloat(representation: representation) {
            self = decimal
        } else {
            return nil
        }
    }
}

extension String {
    public func scan<T: Scannable>(
        for type: T.Type,
        in representation: T.Representation,
        at index: String.Index? = nil,
        ignoredCharacters: Unicode.CharacterSet? = nil,
        isCaseSensitive: Bool = false,
        locale: Locale? = nil
    ) -> T? {
        var scanner = Scanner(scanning: self)
        scanner.scanLocation = index ?? startIndex
        scanner.ignoredCharacters = ignoredCharacters
        scanner.isCaseSensitive = isCaseSensitive
        scanner.locale = locale
        return scanner.scan(for: type, representation: representation)
    }
    
    @available(macOS 10.15, *)
    public func scan<T: Scannable>(
        for type: T.Type,
        in representation: T.Representation = .decimal,
        at index: String.Index? = nil,
        ignoredCharacters: Unicode.CharacterSet? = nil,
        isCaseSensitive: Bool = false,
        locale: Locale? = nil
    ) -> T? where T.Representation == Scanner.NumberRepresentation {
        var scanner = Scanner(scanning: self)
        scanner.scanLocation = index ?? startIndex
        scanner.ignoredCharacters = ignoredCharacters
        scanner.isCaseSensitive = isCaseSensitive
        scanner.locale = locale
        return scanner.scan(for: type, representation: representation)
    }
    
    public func scan<T: Scannable>(
        for type: T.Type,
        at index: String.Index? = nil,
        ignoredCharacters: Unicode.CharacterSet? = nil,
        isCaseSensitive: Bool = false,
        locale: Locale? = nil
    ) -> T? where T.Representation == Void {
        var scanner = Scanner(scanning: self)
        scanner.scanLocation = index ?? startIndex
        scanner.ignoredCharacters = ignoredCharacters
        scanner.isCaseSensitive = isCaseSensitive
        scanner.locale = locale
        return scanner.scan(for: type, representation: ())
    }
    
    @available(macOS 10.15, *)
    public func scan(
        for substring: String,
        at index: String.Index? = nil,
        ignoredCharacters: Unicode.CharacterSet? = nil,
        isCaseSensitive: Bool = false,
        locale: Locale? = nil
    ) -> Bool {
        var scanner = Scanner(scanning: self)
        scanner.scanLocation = index ?? startIndex
        scanner.ignoredCharacters = ignoredCharacters
        scanner.isCaseSensitive = isCaseSensitive
        scanner.locale = locale
        return scanner.scan(for: substring)
    }
    
    @available(macOS 10.15, *)
    public func scan(
        until substring: String,
        at index: String.Index? = nil,
        ignoredCharacters: Unicode.CharacterSet? = nil,
        isCaseSensitive: Bool = false,
        locale: Locale? = nil
    ) -> String? {
        var scanner = Scanner(scanning: self)
        scanner.scanLocation = index ?? startIndex
        scanner.ignoredCharacters = ignoredCharacters
        scanner.isCaseSensitive = isCaseSensitive
        scanner.locale = locale
        return scanner.scan(until: substring)
    }
    
    @available(macOS 10.15, *)
    public func scan(
        while set: CharacterSet,
        at index: String.Index? = nil,
        ignoredCharacters: Unicode.CharacterSet? = nil,
        isCaseSensitive: Bool = false,
        locale: Locale? = nil
    ) -> String? {
        var scanner = Scanner(scanning: self)
        scanner.scanLocation = index ?? startIndex
        scanner.ignoredCharacters = ignoredCharacters
        scanner.isCaseSensitive = isCaseSensitive
        scanner.locale = locale
        return scanner.scan(while: set)
    }
}
/// A regular expression.
///
///
@available(macOS, deprecated: 13.0, message: "Use Swift.Regex instead.")
public struct Regex: RawRepresentable {
    public var rawValue: NSRegularExpression
    
    public init(rawValue: NSRegularExpression) {
        self.rawValue = rawValue
    }
    
    public typealias Options = NSRegularExpression.Options
    public init(_ pattern: String, options: Options = []) throws {
        self.rawValue = try NSRegularExpression(pattern: pattern, options: options)
    }
    
    public var pattern: String { rawValue.pattern }
    public var options: Options { rawValue.options }
    public var numCaptureGroups: Int { rawValue.numberOfCaptureGroups }
    
    public typealias MatchingOptions = NSRegularExpression.MatchingOptions
    public func numMatches<T: StringProtocol>(in string: T, options: MatchingOptions = []) -> Int {
        let string = String(string)
        return self.rawValue.numberOfMatches(in: string, options: options, range: NSRange(location: 0, length: string.count))
    }
    
    public func matches<T: StringProtocol>(in string: T, options: MatchingOptions = []) -> [TextCheckingResult] {
        self.rawValue.matches(in: String(string), options: options, range: NSRange(location: 0, length: string.count)).map { result in
            TextCheckingResult(matching: String(string), result: result)
        }
    }
    
    public func replacingMatches<T: StringProtocol>(in string: T, with template: String, options: MatchingOptions = []) -> String {
        self.rawValue.stringByReplacingMatches(in: String(string), options: options, range: NSRange(location: .zero, length: string.count), withTemplate: template)
    }
    
    public func replaceMatches(in string: inout String, with template: String, options: MatchingOptions = []) {
        string = self.replacingMatches(in: string, with: string)
    }
    
    @dynamicMemberLookup public struct TextCheckingResult {
        public var rawValue: NSTextCheckingResult
        public let string: String
        
        public func range(ofCapture namedCaptureGroup: String) -> Range<String.Index>? {
            let range = rawValue.range(withName: namedCaptureGroup)
            
            if range.location == NSNotFound {
                return nil
            } else {
                let startRange = string.index(string.startIndex, offsetBy: range.lowerBound)
                let endRange = string.index(string.startIndex, offsetBy: range.upperBound)
                
                return startRange..<endRange
            }
        }
        
        public subscript(dynamicMember dynamicMember: String) -> Substring? {
            if let range = range(ofCapture: dynamicMember) {
                return self.string[range]
            } else {
                return nil
            }
        }
        
        public init(matching string: String, result: NSTextCheckingResult) {
            self.string = string
            self.rawValue = result
        }
        
        /// The regex that the result came from.
        public var regex: Regex? {
            rawValue.regularExpression.map(Regex.init)
        }
        
        /// The ranges of the matches.
        public func ranges() -> [Range<String.Index>] {
            return (0..<rawValue.numberOfRanges).map { index in
                rawValue.range(at: index)
            }.map { range in
                let startRange = string.index(string.startIndex, offsetBy: range.lowerBound)
                let endRange = string.index(string.startIndex, offsetBy: range.upperBound)
                
                return startRange..<endRange
            }
        }
        
        public func matches() -> [Substring] {
            self.ranges().map { string[$0] }
        }
    }
}

extension String {
    public func numMatches(of regex: Regex, options: Regex.MatchingOptions = []) -> Int { regex.numMatches(in: self, options: options) }
    
    public func matches(of regex: Regex, options: Regex.MatchingOptions = []) -> [Regex.TextCheckingResult] {
        regex.matches(in: self, options: options)
    }
    
    public func replacingMatches(of regex: Regex, with template: String, options: Regex.MatchingOptions = []) -> String {
        regex.replacingMatches(in: self, with: template, options: options)
    }
    
    public mutating func replaceMatches(of regex: Regex, with template: String, options: Regex.MatchingOptions = []) {
        regex.replaceMatches(in: &self, with: template, options: options)
    }
}

extension OptionSet {
    public static func | (lhs: Self, rhs: Self) -> Self {
        lhs.union(rhs)
    }
}

/// Detects data in a string.
public struct DataDetector: RawRepresentable {
    public var rawValue: NSDataDetector
    
    public init(rawValue: NSDataDetector) {
        self.rawValue = rawValue
    }
    
    public var checkingTypes: CheckingTypes {
        CheckingTypes(rawValue: self.rawValue.checkingTypes)
    }
    
    public typealias Options = NSRegularExpression.Options
    public init(_ pattern: String, options: Options = []) throws {
        self.rawValue = try NSDataDetector(pattern: pattern, options: options)
    }

    public init(_ types: CheckingTypes) throws {
        self.rawValue = try NSDataDetector(types: types.rawValue)
    }
    
    public struct CheckingTypes: OptionSet {
        public var rawValue: UInt64
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }
        
        public static var dateInfo: Self { Self(rawValue: NSTextCheckingResult.CheckingType.date.rawValue) }
        public static var address: Self { Self(rawValue: NSTextCheckingResult.CheckingType.address.rawValue) }
        public static var link: Self { Self(rawValue: NSTextCheckingResult.CheckingType.link.rawValue) }
        public static var phoneNumber: Self { Self(rawValue: NSTextCheckingResult.CheckingType.phoneNumber.rawValue) }
        public static var transitInfo: Self { Self(rawValue: NSTextCheckingResult.CheckingType.transitInformation.rawValue) }
    }
    
    public var pattern: String { rawValue.pattern }
    public var options: Options { rawValue.options }
    public var numCaptureGroups: Int { rawValue.numberOfCaptureGroups }
    
    public typealias MatchingOptions = NSRegularExpression.MatchingOptions
    public func numMatches<T: StringProtocol>(in string: T, options: MatchingOptions = []) -> Int {
        let string = String(string)
        return self.rawValue.numberOfMatches(in: string, options: options, range: NSRange(location: 0, length: string.count))
    }
    
    public func matches<T: StringProtocol>(in string: T, options: MatchingOptions = []) -> [TextCheckingResult] {
        self.rawValue.matches(in: String(string), options: options, range: NSRange(location: 0, length: string.count)).map { result in
            TextCheckingResult(matching: String(string), result: result)
        }
    }
    
    public func replacingMatches<T: StringProtocol>(in string: T, with template: String, options: MatchingOptions = []) -> String {
        self.rawValue.stringByReplacingMatches(in: String(string), options: options, range: NSRange(location: .zero, length: string.count), withTemplate: template)
    }
    
    public func replaceMatches(in string: inout String, with template: String, options: MatchingOptions = []) {
        string = self.replacingMatches(in: string, with: string)
    }
    
    public struct TextCheckingResult {
        public var rawValue: NSTextCheckingResult
        public let string: String
        
        public init(matching string: String, result: NSTextCheckingResult) {
            self.string = string
            self.rawValue = result
        }
        
        /// The regex that the result came from.
        public var regex: Regex? {
            rawValue.regularExpression.map(Regex.init)
        }
        
        /// The ranges of the matches.
        public func ranges() -> [Range<String.Index>] {
            return (0..<rawValue.numberOfRanges).map { index in
                rawValue.range(at: index)
            }.map { range in
                let startRange = string.index(string.startIndex, offsetBy: range.lowerBound)
                let endRange = string.index(string.startIndex, offsetBy: range.upperBound)
                
                return startRange..<endRange
            }
        }
        
        public func matches() -> [Substring] {
            self.ranges().map { string[$0] }
        }
        
        /// The URL that was matched.
        public var link: URL? { rawValue.url }
        /// The address that was matched.
        public var address: Address? { Address(rawValue.addressComponents) }
        
        public var dateInfo: DateInfo? {
            if rawValue.date != nil || rawValue.timeZone != nil {
                return DateInfo(date: rawValue.date, duration: TimeInterval.seconds(rawValue.duration), timeZone: rawValue.timeZone)
            } else {
                return nil
            }
        }
        
        public var transitInfo: TransitInfo? {
            if let components = rawValue.components{
                return TransitInfo(airline: components[.airline], flight: components[.flight])
            } else {
                return nil
            }
        }
        
        public var phoneNumber: String? { rawValue.phoneNumber }
        
        public struct TransitInfo {
            public var airline: String?
            public var flight: String?
        }
        /// The type of result contained within this value.
        public var resultType: DataDetector.CheckingTypes {
            .init(rawValue: self.rawValue.resultType.rawValue)
        }
        
        public struct DateInfo {
            public var date: Date?
            public var duration: Measurement<Duration>?
            public var timeZone: TimeZone?
        }
        
        public struct Address {
            public var city: String?
            public var country: String?
            public var jobTitle: String?
            public var name: String?
            public var organization: String?
            public var phoneNumber: String?
            public var state: String?
            public var street: String?
            public var zipCode: String?
        }
    }
}

extension DataDetector.TextCheckingResult.Address {
    public init(_ keys: [NSTextCheckingKey: String]) {
        self.city = keys[.city]
        self.country = keys[.country]
        self.organization = keys[.organization]
        self.jobTitle = keys[.jobTitle]
        self.state = keys[.state]
        self.name = keys[.name]
        self.phoneNumber = keys[.phone]
        self.street = keys[.street]
        self.zipCode = keys[.zip]
    }
    
    public init?(_ keys: [NSTextCheckingKey: String]?) {
        if let keys {
            self.init(keys)
        } else {
            return nil
        }
    }
}

extension Regex.TextCheckingResult: CustomStringConvertible {
    public var description: String {
        String(describing: self.matches())
    }
}

extension DataDetector.TextCheckingResult: CustomStringConvertible {
    public var description: String {
        String(describing: self.matches())
    }
}
extension String {
    public func detect(_ checkingTypes: DataDetector.CheckingTypes) throws -> [DataDetector.TextCheckingResult] {
        let detector = try DataDetector(checkingTypes)
        return detector.matches(in: self)
    }
    
    
    public func links() throws -> [URL] {
        try self.detect(.link).map(\.link).compactMap { $0 }
    }
    
    public func transitInfo() throws -> [DataDetector.TextCheckingResult.TransitInfo] {
        try self.detect(.transitInfo).map(\.transitInfo).compactMap { $0 }
    }
    
    public func phoneNumbers() throws -> [String] {
        try self.detect(.phoneNumber).map(\.phoneNumber).compactMap { $0 }
    }
    
    public func dateInfo() throws -> [DataDetector.TextCheckingResult.DateInfo] {
        try self.detect(.dateInfo).map(\.dateInfo).compactMap { $0 }
    }
    
    public func addresses() throws -> [DataDetector.TextCheckingResult.Address] {
        try self.detect(.address).map(\.address).compactMap { $0 }
    }
}

extension String {
    public func numMatches(of dataDetector: DataDetector, options: DataDetector.MatchingOptions = []) -> Int { dataDetector.numMatches(in: self, options: options) }
    
    public func matches(of dataDetector: DataDetector, options: DataDetector.MatchingOptions = []) -> [DataDetector.TextCheckingResult] {
        dataDetector.matches(in: self, options: options)
    }
    
    public func replacingMatches(of detector: DataDetector, with template: String, options: DataDetector.MatchingOptions = []) -> String {
        detector.replacingMatches(in: self, with: template, options: options)
    }
    
    public mutating func replaceMatches(of detector: DataDetector, with template: String, options: DataDetector.MatchingOptions = []) {
        detector.replaceMatches(in: &self, with: template, options: options)
    }
}
extension CharacterSet: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(charactersIn: value)
    }
}

public typealias SpellServer = NSSpellServer
public typealias Orthography = NSOrthography

extension Orthography {
    /// Creates the default orthography for `language`.
    /// - Parameter language: The language to create an orthography for.
    /// - Returns: The default orthography for `language`
    @available(macOS 13.0, *)
    public static func `default`(for language: String) -> Orthography {
        Orthography.defaultOrthography(forLanguage: language)
    }
    
    @available(macOS 13.0, *)
    public static func `default`(for locale: Locale) -> Orthography {
        .default(for: locale.language.minimalIdentifier)
    }
    
    /// The default orthography for your language.
    @available(macOS 13.0, *)
    public static var `default`: Orthography {
        .default(for: Locale.current.language.minimalIdentifier)
    }
}

/// Uppercases any string stored inside.
@propertyWrapper public struct Uppercased {
    var _wrappedValue: String
    
    public var wrappedValue: String {
        get {
            _wrappedValue
        } set {
            _wrappedValue = newValue.uppercased()
        }
    }
    
    public init(wrappedValue: String) {
        self._wrappedValue = wrappedValue.uppercased()
    }
}

/// Lowercases any string stored inside.
@propertyWrapper public struct Lowercased {
    var _wrappedValue: String
    
    public var wrappedValue: String {
        get {
            _wrappedValue
        } set {
            _wrappedValue = newValue.lowercased()
        }
    }
    
    public init(wrappedValue: String) {
        self._wrappedValue = wrappedValue.lowercased()
    }
}

/// Normalizes any string stored inside.
@propertyWrapper public struct Capitalized {
    var _wrappedValue: String
    
    public var wrappedValue: String {
        get { _wrappedValue }
        set { _wrappedValue = newValue.capitalized }
    }
    
    public init(wrappedValue: String) {
        self._wrappedValue = wrappedValue.capitalized
    }
}
