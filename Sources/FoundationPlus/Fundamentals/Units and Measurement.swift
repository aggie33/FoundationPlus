import Foundation
/*
/// A unit of measurement.
public protocol UnitProtocol {
    /// The base unit.
    static var base: Self { get }
    
    var symbol: String { get }
}

/// A unit that can be measured in a linear dimension and converted between by a conversion factor.
public protocol DimensionProtocol: UnitProtocol {
    
    /// The amount to multiply a value of this unit by to get a value of the base unit.
    var conversionFactor: Double { get }
}

/// A measurement.
public protocol Measurement: Hashable, Comparable {
    /// The units that are available for this measurement. Usually best modeled by an enum.
    associatedtype Unit: UnitProtocol
    
    /// Returns the given measurement in a specific unit.
    ///
    /// ```swift
    /// let weight: Weight = .pounds(30)
    /// print(weight.value(in: .kilograms))
    /// ```
    func value(in unit: Unit) -> Double
    
    /// Creates a new measurement instance with the specified value and unit.
    ///
    /// ```swift
    /// let distance = Distance(50, .miles)
    /// ```
    init(_ value: Double, _ unit: Unit)
    
    /// Creates a new measurement with the `value` in `baseUnit`.
    init(valueInBaseUnit: Double)
    
    /// The standard unit that this measurement stores its value in.
    
    /// The value of this measurement in its standard unit.
    ///
    /// To make this a more palatable API, you can use the underscored attribute `@_implements`.
    /// ```swift
    /// struct Weight: Measurement {
    ///  ...
    ///  @_implements(Measurement, valueInBaseUnit)
    ///  public var grams: Double { ... }
    /// }
    var valueInBaseUnit: Double { get set }
}

public extension Measurement {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.valueInBaseUnit < rhs.valueInBaseUnit
    }
    
    static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.valueInBaseUnit < rhs.valueInBaseUnit
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool{
        lhs.valueInBaseUnit == rhs.valueInBaseUnit
    }
    
    static var zero: Self {
        Self(0, .base)
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.valueInBaseUnit + rhs.valueInBaseUnit, .base)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        Self(lhs.valueInBaseUnit + rhs.valueInBaseUnit, .base)
    }
    
    static func * (lhs: Self, rhs: Double) -> Self {
        Self(lhs.valueInBaseUnit * rhs, .base)
    }
    
    static func / (lhs: Self, rhs: Double) -> Self {
        Self(lhs.valueInBaseUnit / rhs, .base)
    }
    
    static func convert(_ value: Double, from unit: Unit, to newUnit: Unit) -> Double {
        Self(value, unit).value(in: newUnit)
    }
}

public extension Measurement where Unit: DimensionProtocol {
    func value(in unit: Unit) -> Double {
        valueInBaseUnit / unit.conversionFactor
    }
    
    init(_ value: Double, _ unit: Unit) {
        self.init(valueInBaseUnit: value * unit.conversionFactor)
    }
    
    init(_ value: Double, in unit: Unit) {
        self.init(value, unit)
    }
    
    init<T: BinaryFloatingPoint>(_ value: T, _ unit: Unit) {
        self.init(Double(value), unit)
    }
    
    init<T: BinaryInteger>(_ value: T, _ unit: Unit) {
        self.init(Double(value), unit)
    }
    
    init<T: BinaryFloatingPoint>(_ value: T, in unit: Unit) {
        self.init(Double(value), unit)
    }
    
    init<T: BinaryInteger>(_ value: T, in unit: Unit) {
        self.init(Double(value), unit)
    }
}
*/

public protocol Unit {
    var symbol: String { get }
    static var base: Self { get }
}

public protocol Dimension<Converter>: Unit {
    associatedtype Converter: UnitConverter
    var converter: Converter { get }
    
    init(symbol: String, converter: Converter)
}

public protocol UnitConverter {
    /// Converts `value` from the unit converter's unit to the base unit.
    func convertToBase(_ value: Double) -> Double
    
    /// Converts `value` from the base unit to the unit converter's unit.
    func convertFromBase(_ value: Double) -> Double
}

public struct UnitConverterLinear: UnitConverter, Hashable, Codable {
    public var coefficient: Double
    public var constant: Double
    
    public init(coefficient: Double, constant: Double = 0) {
        self.coefficient = coefficient
        self.constant = constant
    }
    
    public func convertToBase(_ value: Double) -> Double {
        value * coefficient + constant
    }
    
    public func convertFromBase(_ value: Double) -> Double {
        (value - constant) / coefficient
    }
}

/// Finds the reciprocal. Set the `reciprocal` value to 0 to just return the value inputted.
public struct UnitConverterReciprocal: UnitConverter, Hashable, Codable {
    var reciprocal: Double
    
    public func convertToBase(_ value: Double) -> Double {
        reciprocal == 0 ? value : reciprocal / value
    }
    
    public func convertFromBase(_ value: Double) -> Double {
        reciprocal == 0 ? value : reciprocal / value
    }
}

public struct Measurement<UnitType: Unit> {
    public private(set) var unit: UnitType
    public var value: Double
}

extension Measurement where UnitType: Dimension {
    public func value(in unit: UnitType) -> Double {
        UnitType.convert(value, from: self.unit, to: unit)
    }
}

extension Measurement {
    public init(_ value: Double, _ unit: UnitType) {
        self.init(unit: unit, value: value)
    }
    
    public init(value: Double, unit: UnitType) {
        self.init(unit: unit, value: value)
    }
}

extension Measurement: Equatable where UnitType: Dimension {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.converted(to: .base).value == rhs.converted(to: .base).value
    }
}
extension Measurement: Hashable where UnitType: Dimension {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value(in: .base))
    }
}
extension Measurement: Codable where UnitType: Codable {}

public extension Measurement where UnitType: Dimension {
    mutating func convert(to unitType: UnitType) {
        self = Measurement(
            unit: unitType,
            value: unitType.converter.convertFromBase (
                unit.converter.convertToBase(value)
            )
        )
    }
    
    func converted(to unitType: UnitType) -> Measurement<UnitType> {
        Measurement(
            unit: unitType,
            value: unitType.converter.convertFromBase (
                unit.converter.convertToBase(value)
            )
        )
    }
}

public extension Measurement {
    static func * (lhs: Self, rhs: Double) -> Self {
        Self(unit: lhs.unit, value: lhs.value * rhs)
    }
    
    static func / (lhs: Self, rhs: Double) -> Self {
        Self(unit: lhs.unit, value: lhs.value / rhs)
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        Self(unit: lhs.unit, value: lhs.value + rhs.value)
    }
}

extension Measurement: CustomStringConvertible {
    public var description: String {
        "\(value) \(unit.symbol)"
    }
}

public extension Dimension {
    static func convert(_ value: Double, from startUnit: Self, to endUnit: Self) -> Double {
        endUnit.converter.convertFromBase(startUnit.converter.convertToBase(value))
    }
}
public struct Area: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .squareMeters }
}
extension Area {
    public static var squareMeters: Self {
        Self(symbol: "m²", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var squareMegameters: Self {
        Self(symbol: "Mm²", converter: UnitConverterLinear(coefficient: 1e12))
    }
    public static var squareKilometers: Self {
        Self(symbol: "km²", converter: UnitConverterLinear(coefficient: 1000000.0))
    }
    public static var squareCentimeters: Self {
        Self(symbol: "cm²", converter: UnitConverterLinear(coefficient: 0.0001))
    }
    public static var squareMillimeters: Self {
        Self(symbol: "mm²", converter: UnitConverterLinear(coefficient: 0.000001))
    }
    public static var squareMicrometers: Self {
        Self(symbol: "µm²", converter: UnitConverterLinear(coefficient: 1e-12))
    }
    public static var squareNanometers: Self {
        Self(symbol: "nm²", converter: UnitConverterLinear(coefficient: 1e-18))
    }
    public static var squareInches: Self {
        Self(symbol: "in²", converter: UnitConverterLinear(coefficient: 0.00064516))
    }
    public static var squareFeet: Self {
        Self(symbol: "ft²", converter: UnitConverterLinear(coefficient: 0.092903))
    }
    public static var squareYards: Self {
        Self(symbol: "yd²", converter: UnitConverterLinear(coefficient: 0.836127))
    }
    public static var squareMiles: Self {
        Self(symbol: "mi²", converter: UnitConverterLinear(coefficient: 2.59e+6))
    }
    public static var acres: Self {
        Self(symbol: "ac", converter: UnitConverterLinear(coefficient: 4046.86))
    }
    public static var ares: Self {
        Self(symbol: "a", converter: UnitConverterLinear(coefficient: 100))
    }
    public static var hectares: Self {
        Self(symbol: "ha", converter: UnitConverterLinear(coefficient: 10000))
    }
}
extension Measurement where UnitType == Area {
    public var squareMeters: Double {
    value(in: .squareMeters)
}
    public static func squareMeters(_ value: Double) -> Self {
        Self(value, .squareMeters)
    }

    public static func squareMegameters(_ value: Double) -> Self {
        Self(value, .squareMegameters)
    }

    public var squareMegameters: Double {
        UnitType.convert(value, from: unit, to: .squareMegameters)
    }

    public static func squareKilometers(_ value: Double) -> Self {
        Self(value, .squareKilometers)
    }

    public var squareKilometers: Double {
        UnitType.convert(value, from: unit, to: .squareKilometers)
    }

    public static func squareCentimeters(_ value: Double) -> Self {
        Self(value, .squareCentimeters)
    }

    public var squareCentimeters: Double {
        UnitType.convert(value, from: unit, to: .squareCentimeters)
    }

    public static func squareMillimeters(_ value: Double) -> Self {
        Self(value, .squareMillimeters)
    }

    public var squareMillimeters: Double {
        UnitType.convert(value, from: unit, to: .squareMillimeters)
    }

    public static func squareMicrometers(_ value: Double) -> Self {
        Self(value, .squareMicrometers)
    }

    public var squareMicrometers: Double {
        UnitType.convert(value, from: unit, to: .squareMicrometers)
    }

    public static func squareNanometers(_ value: Double) -> Self {
        Self(value, .squareNanometers)
    }

    public var squareNanometers: Double {
        UnitType.convert(value, from: unit, to: .squareNanometers)
    }

    public static func squareInches(_ value: Double) -> Self {
        Self(value, .squareInches)
    }

    public var squareInches: Double {
        UnitType.convert(value, from: unit, to: .squareInches)
    }

    public static func squareFeet(_ value: Double) -> Self {
        Self(value, .squareFeet)
    }

    public var squareFeet: Double {
        UnitType.convert(value, from: unit, to: .squareFeet)
    }

    public static func squareYards(_ value: Double) -> Self {
        Self(value, .squareYards)
    }

    public var squareYards: Double {
        UnitType.convert(value, from: unit, to: .squareYards)
    }

    public static func squareMiles(_ value: Double) -> Self {
        Self(value, .squareMiles)
    }

    public var squareMiles: Double {
        UnitType.convert(value, from: unit, to: .squareMiles)
    }

    public static func acres(_ value: Double) -> Self {
        Self(value, .acres)
    }

    public var acres: Double {
        UnitType.convert(value, from: unit, to: .acres)
    }

    public static func ares(_ value: Double) -> Self {
        Self(value, .ares)
    }

    public var ares: Double {
        UnitType.convert(value, from: unit, to: .ares)
    }

    public static func hectares(_ value: Double) -> Self {
        Self(value, .hectares)
    }

    public var hectares: Double {
        UnitType.convert(value, from: unit, to: .hectares)
    }

}

public struct Length: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .meters }
}
extension Length {
    public static var meters: Self {
        Self(symbol: "m", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var megameters: Self {
        Self(symbol: "Mm", converter: UnitConverterLinear(coefficient: 1000000.0))
    }
    public static var kilometers: Self {
        Self(symbol: "kM", converter: UnitConverterLinear(coefficient: 1000.0))
    }
    public static var hectometers: Self {
        Self(symbol: "hm", converter: UnitConverterLinear(coefficient: 100.0))
    }
    public static var decameters: Self {
        Self(symbol: "dam", converter: UnitConverterLinear(coefficient: 10.0))
    }
    public static var decimeters: Self {
        Self(symbol: "dm", converter: UnitConverterLinear(coefficient: 0.1))
    }
    public static var centimeters: Self {
        Self(symbol: "cm", converter: UnitConverterLinear(coefficient: 0.01))
    }
    public static var millimeters: Self {
        Self(symbol: "mm", converter: UnitConverterLinear(coefficient: 0.001))
    }
    public static var micrometers: Self {
        Self(symbol: "µm", converter: UnitConverterLinear(coefficient: 0.000001))
    }
    public static var nanometers: Self {
        Self(symbol: "nm", converter: UnitConverterLinear(coefficient: 1e-9))
    }
    public static var picometers: Self {
        Self(symbol: "pm", converter: UnitConverterLinear(coefficient: 1e-12))
    }
    public static var inches: Self {
        Self(symbol: "in", converter: UnitConverterLinear(coefficient: 0.0254))
    }
    public static var feet: Self {
        Self(symbol: "ft", converter: UnitConverterLinear(coefficient: 0.3048))
    }
    public static var yards: Self {
        Self(symbol: "yd", converter: UnitConverterLinear(coefficient: 0.9144))
    }
    public static var miles: Self {
        Self(symbol: "mi", converter: UnitConverterLinear(coefficient: 1609.34))
    }
    public static var scandinavianMiles: Self {
        Self(symbol: "smi", converter: UnitConverterLinear(coefficient: 10000))
    }
    public static var lightyears: Self {
        Self(symbol: "ly", converter: UnitConverterLinear(coefficient: 9.461e+15))
    }
    public static var nauticalMiles: Self {
        Self(symbol: "NM", converter: UnitConverterLinear(coefficient: 1852))
    }
    public static var fathoms: Self {
        Self(symbol: "ftm", converter: UnitConverterLinear(coefficient: 1.8288))
    }
    public static var furlongs: Self {
        Self(symbol: "fur", converter: UnitConverterLinear(coefficient: 201.168))
    }
    public static var astronomicalUnits: Self {
        Self(symbol: "ua", converter: UnitConverterLinear(coefficient: 1.496e+11))
    }
    public static var parsecs: Self {
        Self(symbol: "pc", converter: UnitConverterLinear(coefficient: 3.086e+16))
    }
}
extension Measurement where UnitType == Length {
    public var meters: Double {
    value(in: .meters)
}
    public static func meters(_ value: Double) -> Self {
        Self(value, .meters)
    }

    public static func megameters(_ value: Double) -> Self {
        Self(value, .megameters)
    }

    public var megameters: Double {
        UnitType.convert(value, from: unit, to: .megameters)
    }

    public static func kilometers(_ value: Double) -> Self {
        Self(value, .kilometers)
    }

    public var kilometers: Double {
        UnitType.convert(value, from: unit, to: .kilometers)
    }

    public static func hectometers(_ value: Double) -> Self {
        Self(value, .hectometers)
    }

    public var hectometers: Double {
        UnitType.convert(value, from: unit, to: .hectometers)
    }

    public static func decameters(_ value: Double) -> Self {
        Self(value, .decameters)
    }

    public var decameters: Double {
        UnitType.convert(value, from: unit, to: .decameters)
    }

    public static func decimeters(_ value: Double) -> Self {
        Self(value, .decimeters)
    }

    public var decimeters: Double {
        UnitType.convert(value, from: unit, to: .decimeters)
    }

    public static func centimeters(_ value: Double) -> Self {
        Self(value, .centimeters)
    }

    public var centimeters: Double {
        UnitType.convert(value, from: unit, to: .centimeters)
    }

    public static func millimeters(_ value: Double) -> Self {
        Self(value, .millimeters)
    }

    public var millimeters: Double {
        UnitType.convert(value, from: unit, to: .millimeters)
    }

    public static func micrometers(_ value: Double) -> Self {
        Self(value, .micrometers)
    }

    public var micrometers: Double {
        UnitType.convert(value, from: unit, to: .micrometers)
    }

    public static func nanometers(_ value: Double) -> Self {
        Self(value, .nanometers)
    }

    public var nanometers: Double {
        UnitType.convert(value, from: unit, to: .nanometers)
    }

    public static func picometers(_ value: Double) -> Self {
        Self(value, .picometers)
    }

    public var picometers: Double {
        UnitType.convert(value, from: unit, to: .picometers)
    }

    public static func inches(_ value: Double) -> Self {
        Self(value, .inches)
    }

    public var inches: Double {
        UnitType.convert(value, from: unit, to: .inches)
    }

    public static func feet(_ value: Double) -> Self {
        Self(value, .feet)
    }

    public var feet: Double {
        UnitType.convert(value, from: unit, to: .feet)
    }

    public static func yards(_ value: Double) -> Self {
        Self(value, .yards)
    }

    public var yards: Double {
        UnitType.convert(value, from: unit, to: .yards)
    }

    public static func miles(_ value: Double) -> Self {
        Self(value, .miles)
    }

    public var miles: Double {
        UnitType.convert(value, from: unit, to: .miles)
    }

    public static func scandinavianMiles(_ value: Double) -> Self {
        Self(value, .scandinavianMiles)
    }

    public var scandinavianMiles: Double {
        UnitType.convert(value, from: unit, to: .scandinavianMiles)
    }

    public static func lightyears(_ value: Double) -> Self {
        Self(value, .lightyears)
    }

    public var lightyears: Double {
        UnitType.convert(value, from: unit, to: .lightyears)
    }

    public static func nauticalMiles(_ value: Double) -> Self {
        Self(value, .nauticalMiles)
    }

    public var nauticalMiles: Double {
        UnitType.convert(value, from: unit, to: .nauticalMiles)
    }

    public static func fathoms(_ value: Double) -> Self {
        Self(value, .fathoms)
    }

    public var fathoms: Double {
        UnitType.convert(value, from: unit, to: .fathoms)
    }

    public static func furlongs(_ value: Double) -> Self {
        Self(value, .furlongs)
    }

    public var furlongs: Double {
        UnitType.convert(value, from: unit, to: .furlongs)
    }

    public static func astronomicalUnits(_ value: Double) -> Self {
        Self(value, .astronomicalUnits)
    }

    public var astronomicalUnits: Double {
        UnitType.convert(value, from: unit, to: .astronomicalUnits)
    }

    public static func parsecs(_ value: Double) -> Self {
        Self(value, .parsecs)
    }

    public var parsecs: Double {
        UnitType.convert(value, from: unit, to: .parsecs)
    }

}

public struct Duration: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .seconds }
}
extension Duration {
    public static var seconds: Self {
        Self(symbol: "sec", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var minutes: Self {
        Self(symbol: "min", converter: UnitConverterLinear(coefficient: 60))
    }
    public static var hours: Self {
        Self(symbol: "hr", converter: UnitConverterLinear(coefficient: 3600))
    }
    public static var milliseconds: Self {
        Self(symbol: "ms", converter: UnitConverterLinear(coefficient: 1e-3))
    }
    public static var microseconds: Self {
        Self(symbol: "μs", converter: UnitConverterLinear(coefficient: 1e-6))
    }
    public static var nanoseconds: Self {
        Self(symbol: "ns", converter: UnitConverterLinear(coefficient: 1e-9))
    }
    public static var picoseconds: Self {
        Self(symbol: "ps", converter: UnitConverterLinear(coefficient: 1e-12))
    }
}
extension Measurement where UnitType == Duration {
    public static func / (lhs: Measurement<Length>, rhs: Measurement<Duration>) -> Measurement<Speed> {
        Measurement<Speed>(lhs.value / rhs.value, Speed(symbol: "\(lhs.unit.symbol)/\(rhs.unit.symbol)", converter: Speed.Converter(coefficient: lhs.unit.converter.coefficient / rhs.unit.converter.coefficient)))
    }
    
    public var seconds: Double {
    value(in: .seconds)
}
    public static func seconds(_ value: Double) -> Self {
        Self(value, .seconds)
    }

    public static func minutes(_ value: Double) -> Self {
        Self(value, .minutes)
    }

    public var minutes: Double {
        UnitType.convert(value, from: unit, to: .minutes)
    }

    public static func hours(_ value: Double) -> Self {
        Self(value, .hours)
    }

    public var hours: Double {
        UnitType.convert(value, from: unit, to: .hours)
    }

    public static func milliseconds(_ value: Double) -> Self {
        Self(value, .milliseconds)
    }

    public var milliseconds: Double {
        UnitType.convert(value, from: unit, to: .milliseconds)
    }

    public static func microseconds(_ value: Double) -> Self {
        Self(value, .microseconds)
    }

    public var microseconds: Double {
        UnitType.convert(value, from: unit, to: .microseconds)
    }

    public static func nanoseconds(_ value: Double) -> Self {
        Self(value, .nanoseconds)
    }

    public var nanoseconds: Double {
        UnitType.convert(value, from: unit, to: .nanoseconds)
    }

    public static func picoseconds(_ value: Double) -> Self {
        Self(value, .picoseconds)
    }

    public var picoseconds: Double {
        UnitType.convert(value, from: unit, to: .picoseconds)
    }

}

public struct Angle: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .degrees }
}
extension Angle {
    public static var degrees: Self {
        Self(symbol: "°", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var arcMinutes: Self {
        Self(symbol: "ʹ", converter: UnitConverterLinear(coefficient: 0.016667))
    }
    public static var arcSeconds: Self {
        Self(symbol: "ʺ", converter: UnitConverterLinear(coefficient: 0.00027778))
    }
    public static var radians: Self {
        Self(symbol: "rad", converter: UnitConverterLinear(coefficient: 57.2958))
    }
    public static var gradians: Self {
        Self(symbol: "grad", converter: UnitConverterLinear(coefficient: 0.9))
    }
    public static var revolutions: Self {
        Self(symbol: "rev", converter: UnitConverterLinear(coefficient: 360))
    }
}
extension Measurement where UnitType == Angle {
    public var degrees: Double {
    value(in: .degrees)
}
    public static func degrees(_ value: Double) -> Self {
        Self(value, .degrees)
    }

    public static func arcMinutes(_ value: Double) -> Self {
        Self(value, .arcMinutes)
    }

    public var arcMinutes: Double {
        UnitType.convert(value, from: unit, to: .arcMinutes)
    }

    public static func arcSeconds(_ value: Double) -> Self {
        Self(value, .arcSeconds)
    }

    public var arcSeconds: Double {
        UnitType.convert(value, from: unit, to: .arcSeconds)
    }

    public static func radians(_ value: Double) -> Self {
        Self(value, .radians)
    }

    public var radians: Double {
        UnitType.convert(value, from: unit, to: .radians)
    }

    public static func gradians(_ value: Double) -> Self {
        Self(value, .gradians)
    }

    public var gradians: Double {
        UnitType.convert(value, from: unit, to: .gradians)
    }

    public static func revolutions(_ value: Double) -> Self {
        Self(value, .revolutions)
    }

    public var revolutions: Double {
        UnitType.convert(value, from: unit, to: .revolutions)
    }

}

public struct Volume: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .cubicDecimeters }
}
extension Volume {
    public static var cubicDecimeters: Self {
        Self(symbol: "dm³", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var megaliters: Self {
        Self(symbol: "ML", converter: UnitConverterLinear(coefficient: 1000000.0))
    }
    public static var kiloliters: Self {
        Self(symbol: "kL", converter: UnitConverterLinear(coefficient: 1000.0))
    }
    public static var deciliters: Self {
        Self(symbol: "dL", converter: UnitConverterLinear(coefficient: 0.1))
    }
    public static var centiliters: Self {
        Self(symbol: "cL", converter: UnitConverterLinear(coefficient: 0.01))
    }
    public static var milliliters: Self {
        Self(symbol: "mL", converter: UnitConverterLinear(coefficient: 0.001))
    }
    public static var cubicKilometers: Self {
        Self(symbol: "km³", converter: UnitConverterLinear(coefficient: 1e12))
    }
    public static var cubicMeters: Self {
        Self(symbol: "m³", converter: UnitConverterLinear(coefficient: 1000.0))
    }
    public static var cubicMillimeters: Self {
        Self(symbol: "mm³", converter: UnitConverterLinear(coefficient: 0.000001))
    }
    public static var cubicInches: Self {
        Self(symbol: "in³", converter: UnitConverterLinear(coefficient: 0.0163871))
    }
    public static var cubicFeet: Self {
        Self(symbol: "ft³", converter: UnitConverterLinear(coefficient: 28.3168))
    }
    public static var cubicYards: Self {
        Self(symbol: "yd³", converter: UnitConverterLinear(coefficient: 764.555))
    }
    public static var cubicMiles: Self {
        Self(symbol: "mi³", converter: UnitConverterLinear(coefficient: 4.168e+12))
    }
    public static var acreFeet: Self {
        Self(symbol: "af", converter: UnitConverterLinear(coefficient: 1.233e+6))
    }
    public static var bushels: Self {
        Self(symbol: "bsh", converter: UnitConverterLinear(coefficient: 35.2391))
    }
    public static var teaspoons: Self {
        Self(symbol: "tsp", converter: UnitConverterLinear(coefficient: 0.00492892))
    }
    public static var tablespoons: Self {
        Self(symbol: "tbsp", converter: UnitConverterLinear(coefficient: 0.0147868))
    }
    public static var fluidOunces: Self {
        Self(symbol: "fl oz", converter: UnitConverterLinear(coefficient: 0.0295735))
    }
    public static var cups: Self {
        Self(symbol: "cup", converter: UnitConverterLinear(coefficient: 0.24))
    }
    public static var pints: Self {
        Self(symbol: "pt", converter: UnitConverterLinear(coefficient: 0.473176))
    }
    public static var quarts: Self {
        Self(symbol: "qt", converter: UnitConverterLinear(coefficient: 0.946353))
    }
    public static var gallons: Self {
        Self(symbol: "gal", converter: UnitConverterLinear(coefficient: 3.78541))
    }
    public static var imperialTeaspoons: Self {
        Self(symbol: "tsp", converter: UnitConverterLinear(coefficient: 0.00591939))
    }
    public static var imperialTablespoons: Self {
        Self(symbol: "tbsp", converter: UnitConverterLinear(coefficient: 0.0177582))
    }
    public static var imperialFluidOunces: Self {
        Self(symbol: "fl oz", converter: UnitConverterLinear(coefficient: 0.0284131))
    }
    public static var imperialPints: Self {
        Self(symbol: "pt", converter: UnitConverterLinear(coefficient: 0.568261))
    }
    public static var imperialQuarts: Self {
        Self(symbol: "qt", converter: UnitConverterLinear(coefficient: 1.13652))
    }
    public static var imperialGallons: Self {
        Self(symbol: "gal", converter: UnitConverterLinear(coefficient: 4.54609))
    }
    public static var metricCups: Self {
        Self(symbol: "metric cup", converter: UnitConverterLinear(coefficient: 0.25))
    }
}
extension Measurement where UnitType == Volume {
    public var cubicDecimeters: Double {
    value(in: .cubicDecimeters)
}
    public static func cubicDecimeters(_ value: Double) -> Self {
        Self(value, .cubicDecimeters)
    }

    public static func megaliters(_ value: Double) -> Self {
        Self(value, .megaliters)
    }

    public var megaliters: Double {
        UnitType.convert(value, from: unit, to: .megaliters)
    }

    public static func kiloliters(_ value: Double) -> Self {
        Self(value, .kiloliters)
    }

    public var kiloliters: Double {
        UnitType.convert(value, from: unit, to: .kiloliters)
    }

    public static func deciliters(_ value: Double) -> Self {
        Self(value, .deciliters)
    }

    public var deciliters: Double {
        UnitType.convert(value, from: unit, to: .deciliters)
    }

    public static func centiliters(_ value: Double) -> Self {
        Self(value, .centiliters)
    }

    public var centiliters: Double {
        UnitType.convert(value, from: unit, to: .centiliters)
    }

    public static func milliliters(_ value: Double) -> Self {
        Self(value, .milliliters)
    }

    public var milliliters: Double {
        UnitType.convert(value, from: unit, to: .milliliters)
    }

    public static func cubicKilometers(_ value: Double) -> Self {
        Self(value, .cubicKilometers)
    }

    public var cubicKilometers: Double {
        UnitType.convert(value, from: unit, to: .cubicKilometers)
    }

    public static func cubicMeters(_ value: Double) -> Self {
        Self(value, .cubicMeters)
    }

    public var cubicMeters: Double {
        UnitType.convert(value, from: unit, to: .cubicMeters)
    }

    public static func cubicMillimeters(_ value: Double) -> Self {
        Self(value, .cubicMillimeters)
    }

    public var cubicMillimeters: Double {
        UnitType.convert(value, from: unit, to: .cubicMillimeters)
    }

    public static func cubicInches(_ value: Double) -> Self {
        Self(value, .cubicInches)
    }

    public var cubicInches: Double {
        UnitType.convert(value, from: unit, to: .cubicInches)
    }

    public static func cubicFeet(_ value: Double) -> Self {
        Self(value, .cubicFeet)
    }

    public var cubicFeet: Double {
        UnitType.convert(value, from: unit, to: .cubicFeet)
    }

    public static func cubicYards(_ value: Double) -> Self {
        Self(value, .cubicYards)
    }

    public var cubicYards: Double {
        UnitType.convert(value, from: unit, to: .cubicYards)
    }

    public static func cubicMiles(_ value: Double) -> Self {
        Self(value, .cubicMiles)
    }

    public var cubicMiles: Double {
        UnitType.convert(value, from: unit, to: .cubicMiles)
    }

    public static func acreFeet(_ value: Double) -> Self {
        Self(value, .acreFeet)
    }

    public var acreFeet: Double {
        UnitType.convert(value, from: unit, to: .acreFeet)
    }

    public static func bushels(_ value: Double) -> Self {
        Self(value, .bushels)
    }

    public var bushels: Double {
        UnitType.convert(value, from: unit, to: .bushels)
    }

    public static func teaspoons(_ value: Double) -> Self {
        Self(value, .teaspoons)
    }

    public var teaspoons: Double {
        UnitType.convert(value, from: unit, to: .teaspoons)
    }

    public static func tablespoons(_ value: Double) -> Self {
        Self(value, .tablespoons)
    }

    public var tablespoons: Double {
        UnitType.convert(value, from: unit, to: .tablespoons)
    }

    public static func fluidOunces(_ value: Double) -> Self {
        Self(value, .fluidOunces)
    }

    public var fluidOunces: Double {
        UnitType.convert(value, from: unit, to: .fluidOunces)
    }

    public static func cups(_ value: Double) -> Self {
        Self(value, .cups)
    }

    public var cups: Double {
        UnitType.convert(value, from: unit, to: .cups)
    }

    public static func pints(_ value: Double) -> Self {
        Self(value, .pints)
    }

    public var pints: Double {
        UnitType.convert(value, from: unit, to: .pints)
    }

    public static func quarts(_ value: Double) -> Self {
        Self(value, .quarts)
    }

    public var quarts: Double {
        UnitType.convert(value, from: unit, to: .quarts)
    }

    public static func gallons(_ value: Double) -> Self {
        Self(value, .gallons)
    }

    public var gallons: Double {
        UnitType.convert(value, from: unit, to: .gallons)
    }

    public static func imperialTeaspoons(_ value: Double) -> Self {
        Self(value, .imperialTeaspoons)
    }

    public var imperialTeaspoons: Double {
        UnitType.convert(value, from: unit, to: .imperialTeaspoons)
    }

    public static func imperialTablespoons(_ value: Double) -> Self {
        Self(value, .imperialTablespoons)
    }

    public var imperialTablespoons: Double {
        UnitType.convert(value, from: unit, to: .imperialTablespoons)
    }

    public static func imperialFluidOunces(_ value: Double) -> Self {
        Self(value, .imperialFluidOunces)
    }

    public var imperialFluidOunces: Double {
        UnitType.convert(value, from: unit, to: .imperialFluidOunces)
    }

    public static func imperialPints(_ value: Double) -> Self {
        Self(value, .imperialPints)
    }

    public var imperialPints: Double {
        UnitType.convert(value, from: unit, to: .imperialPints)
    }

    public static func imperialQuarts(_ value: Double) -> Self {
        Self(value, .imperialQuarts)
    }

    public var imperialQuarts: Double {
        UnitType.convert(value, from: unit, to: .imperialQuarts)
    }

    public static func imperialGallons(_ value: Double) -> Self {
        Self(value, .imperialGallons)
    }

    public var imperialGallons: Double {
        UnitType.convert(value, from: unit, to: .imperialGallons)
    }

    public static func metricCups(_ value: Double) -> Self {
        Self(value, .metricCups)
    }

    public var metricCups: Double {
        UnitType.convert(value, from: unit, to: .metricCups)
    }

}

public struct Mass: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .kilograms }
}
extension Mass {
    public static var kilograms: Self {
        Self(symbol: "kg", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var grams: Self {
        Self(symbol: "g", converter: UnitConverterLinear(coefficient: 0.001))
    }
    public static var decigrams: Self {
        Self(symbol: "dg", converter: UnitConverterLinear(coefficient: 0.0001))
    }
    public static var centigrams: Self {
        Self(symbol: "cg", converter: UnitConverterLinear(coefficient: 0.00001))
    }
    public static var milligrams: Self {
        Self(symbol: "mg", converter: UnitConverterLinear(coefficient: 0.000001))
    }
    public static var micrograms: Self {
        Self(symbol: "µg", converter: UnitConverterLinear(coefficient: 1e9))
    }
    public static var nanograms: Self {
        Self(symbol: "ng", converter: UnitConverterLinear(coefficient: 1e-12))
    }
    public static var picograms: Self {
        Self(symbol: "pg", converter: UnitConverterLinear(coefficient: 1e-15))
    }
    public static var ounces: Self {
        Self(symbol: "oz", converter: UnitConverterLinear(coefficient: 0.0283495))
    }
    public static var pounds: Self {
        Self(symbol: "lb", converter: UnitConverterLinear(coefficient: 0.453592))
    }
    public static var stones: Self {
        Self(symbol: "st", converter: UnitConverterLinear(coefficient: 0.157473))
    }
    public static var metricTons: Self {
        Self(symbol: "t", converter: UnitConverterLinear(coefficient: 1000))
    }
    public static var shortTons: Self {
        Self(symbol: "ton", converter: UnitConverterLinear(coefficient: 907.185))
    }
    public static var carats: Self {
        Self(symbol: "ct", converter: UnitConverterLinear(coefficient: 0.0002))
    }
    public static var ouncesTroy: Self {
        Self(symbol: "oz t", converter: UnitConverterLinear(coefficient: 0.03110348))
    }
    public static var slugs: Self {
        Self(symbol: "slug", converter: UnitConverterLinear(coefficient: 14.5939))
    }
}
extension Measurement where UnitType == Mass {
    public var kilograms: Double {
    value(in: .kilograms)
}
    public static func kilograms(_ value: Double) -> Self {
        Self(value, .kilograms)
    }

    public static func grams(_ value: Double) -> Self {
        Self(value, .grams)
    }

    public var grams: Double {
        UnitType.convert(value, from: unit, to: .grams)
    }

    public static func decigrams(_ value: Double) -> Self {
        Self(value, .decigrams)
    }

    public var decigrams: Double {
        UnitType.convert(value, from: unit, to: .decigrams)
    }

    public static func centigrams(_ value: Double) -> Self {
        Self(value, .centigrams)
    }

    public var centigrams: Double {
        UnitType.convert(value, from: unit, to: .centigrams)
    }

    public static func milligrams(_ value: Double) -> Self {
        Self(value, .milligrams)
    }

    public var milligrams: Double {
        UnitType.convert(value, from: unit, to: .milligrams)
    }

    public static func micrograms(_ value: Double) -> Self {
        Self(value, .micrograms)
    }

    public var micrograms: Double {
        UnitType.convert(value, from: unit, to: .micrograms)
    }

    public static func nanograms(_ value: Double) -> Self {
        Self(value, .nanograms)
    }

    public var nanograms: Double {
        UnitType.convert(value, from: unit, to: .nanograms)
    }

    public static func picograms(_ value: Double) -> Self {
        Self(value, .picograms)
    }

    public var picograms: Double {
        UnitType.convert(value, from: unit, to: .picograms)
    }

    public static func ounces(_ value: Double) -> Self {
        Self(value, .ounces)
    }

    public var ounces: Double {
        UnitType.convert(value, from: unit, to: .ounces)
    }

    public static func pounds(_ value: Double) -> Self {
        Self(value, .pounds)
    }

    public var pounds: Double {
        UnitType.convert(value, from: unit, to: .pounds)
    }

    public static func stones(_ value: Double) -> Self {
        Self(value, .stones)
    }

    public var stones: Double {
        UnitType.convert(value, from: unit, to: .stones)
    }

    public static func metricTons(_ value: Double) -> Self {
        Self(value, .metricTons)
    }

    public var metricTons: Double {
        UnitType.convert(value, from: unit, to: .metricTons)
    }

    public static func shortTons(_ value: Double) -> Self {
        Self(value, .shortTons)
    }

    public var shortTons: Double {
        UnitType.convert(value, from: unit, to: .shortTons)
    }

    public static func carats(_ value: Double) -> Self {
        Self(value, .carats)
    }

    public var carats: Double {
        UnitType.convert(value, from: unit, to: .carats)
    }

    public static func ouncesTroy(_ value: Double) -> Self {
        Self(value, .ouncesTroy)
    }

    public var ouncesTroy: Double {
        UnitType.convert(value, from: unit, to: .ouncesTroy)
    }

    public static func slugs(_ value: Double) -> Self {
        Self(value, .slugs)
    }

    public var slugs: Double {
        UnitType.convert(value, from: unit, to: .slugs)
    }

}

public struct Pressure: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .newtonsPerMetersSquared }
}
extension Pressure {
    public static var newtonsPerMetersSquared: Self {
        Self(symbol: "N/m²", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var gigapascals: Self {
        Self(symbol: "GPa", converter: UnitConverterLinear(coefficient: 1e9))
    }
    public static var megapascals: Self {
        Self(symbol: "MPa", converter: UnitConverterLinear(coefficient: 1000000.0))
    }
    public static var kilopascals: Self {
        Self(symbol: "kPa", converter: UnitConverterLinear(coefficient: 1000.0))
    }
    public static var hectopascals: Self {
        Self(symbol: "hPa", converter: UnitConverterLinear(coefficient: 100.0))
    }
    public static var inchesOfMercury: Self {
        Self(symbol: "inHg", converter: UnitConverterLinear(coefficient: 3386.39))
    }
    public static var bars: Self {
        Self(symbol: "bar", converter: UnitConverterLinear(coefficient: 100000))
    }
    public static var millibars: Self {
        Self(symbol: "mbar", converter: UnitConverterLinear(coefficient: 100))
    }
    public static var millimetersOfMercury: Self {
        Self(symbol: "mmHg", converter: UnitConverterLinear(coefficient: 133.322))
    }
    public static var poundsForcePerSquareInch: Self {
        Self(symbol: "psi", converter: UnitConverterLinear(coefficient: 6894.76))
    }
}
extension Measurement where UnitType == Pressure {
    public var newtonsPerMetersSquared: Double {
    value(in: .newtonsPerMetersSquared)
}
    public static func newtonsPerMetersSquared(_ value: Double) -> Self {
        Self(value, .newtonsPerMetersSquared)
    }

    public static func gigapascals(_ value: Double) -> Self {
        Self(value, .gigapascals)
    }

    public var gigapascals: Double {
        UnitType.convert(value, from: unit, to: .gigapascals)
    }

    public static func megapascals(_ value: Double) -> Self {
        Self(value, .megapascals)
    }

    public var megapascals: Double {
        UnitType.convert(value, from: unit, to: .megapascals)
    }

    public static func kilopascals(_ value: Double) -> Self {
        Self(value, .kilopascals)
    }

    public var kilopascals: Double {
        UnitType.convert(value, from: unit, to: .kilopascals)
    }

    public static func hectopascals(_ value: Double) -> Self {
        Self(value, .hectopascals)
    }

    public var hectopascals: Double {
        UnitType.convert(value, from: unit, to: .hectopascals)
    }

    public static func inchesOfMercury(_ value: Double) -> Self {
        Self(value, .inchesOfMercury)
    }

    public var inchesOfMercury: Double {
        UnitType.convert(value, from: unit, to: .inchesOfMercury)
    }

    public static func bars(_ value: Double) -> Self {
        Self(value, .bars)
    }

    public var bars: Double {
        UnitType.convert(value, from: unit, to: .bars)
    }

    public static func millibars(_ value: Double) -> Self {
        Self(value, .millibars)
    }

    public var millibars: Double {
        UnitType.convert(value, from: unit, to: .millibars)
    }

    public static func millimetersOfMercury(_ value: Double) -> Self {
        Self(value, .millimetersOfMercury)
    }

    public var millimetersOfMercury: Double {
        UnitType.convert(value, from: unit, to: .millimetersOfMercury)
    }

    public static func poundsForcePerSquareInch(_ value: Double) -> Self {
        Self(value, .poundsForcePerSquareInch)
    }

    public var poundsForcePerSquareInch: Double {
        UnitType.convert(value, from: unit, to: .poundsForcePerSquareInch)
    }

}

public struct Acceleration: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .metersPerSecondSquared }
}
extension Acceleration {
    public static var metersPerSecondSquared: Self {
        Self(symbol: "m/s²", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var gravity: Self {
        Self(symbol: "g", converter: UnitConverterLinear(coefficient: 9.81))
    }
}
extension Measurement where UnitType == Acceleration {
    public var metersPerSecondSquared: Double {
    value(in: .metersPerSecondSquared)
}
    public static func metersPerSecondSquared(_ value: Double) -> Self {
        Self(value, .metersPerSecondSquared)
    }

    public static func gravity(_ value: Double) -> Self {
        Self(value, .gravity)
    }

    public var gravity: Double {
        UnitType.convert(value, from: unit, to: .gravity)
    }

}

public struct Frequency: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .hertz }
}
extension Frequency {
    public static var hertz: Self {
        Self(symbol: "Hz", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var terahertz: Self {
        Self(symbol: "THz", converter: UnitConverterLinear(coefficient: 1e12))
    }
    public static var gigahertz: Self {
        Self(symbol: "GHz", converter: UnitConverterLinear(coefficient: 1e9))
    }
    public static var megahertz: Self {
        Self(symbol: "MHz", converter: UnitConverterLinear(coefficient: 1000000.0))
    }
    public static var kilohertz: Self {
        Self(symbol: "kHz", converter: UnitConverterLinear(coefficient: 1000.0))
    }
    public static var millihertz: Self {
        Self(symbol: "mHz", converter: UnitConverterLinear(coefficient: 0.001))
    }
    public static var microhertz: Self {
        Self(symbol: "µHz", converter: UnitConverterLinear(coefficient: 0.000001))
    }
    public static var nanohertz: Self {
        Self(symbol: "nHz", converter: UnitConverterLinear(coefficient: 1e-9))
    }
}
extension Measurement where UnitType == Frequency {
    public var hertz: Double {
    value(in: .hertz)
}
    public static func hertz(_ value: Double) -> Self {
        Self(value, .hertz)
    }

    public static func terahertz(_ value: Double) -> Self {
        Self(value, .terahertz)
    }

    public var terahertz: Double {
        UnitType.convert(value, from: unit, to: .terahertz)
    }

    public static func gigahertz(_ value: Double) -> Self {
        Self(value, .gigahertz)
    }

    public var gigahertz: Double {
        UnitType.convert(value, from: unit, to: .gigahertz)
    }

    public static func megahertz(_ value: Double) -> Self {
        Self(value, .megahertz)
    }

    public var megahertz: Double {
        UnitType.convert(value, from: unit, to: .megahertz)
    }

    public static func kilohertz(_ value: Double) -> Self {
        Self(value, .kilohertz)
    }

    public var kilohertz: Double {
        UnitType.convert(value, from: unit, to: .kilohertz)
    }

    public static func millihertz(_ value: Double) -> Self {
        Self(value, .millihertz)
    }

    public var millihertz: Double {
        UnitType.convert(value, from: unit, to: .millihertz)
    }

    public static func microhertz(_ value: Double) -> Self {
        Self(value, .microhertz)
    }

    public var microhertz: Double {
        UnitType.convert(value, from: unit, to: .microhertz)
    }

    public static func nanohertz(_ value: Double) -> Self {
        Self(value, .nanohertz)
    }

    public var nanohertz: Double {
        UnitType.convert(value, from: unit, to: .nanohertz)
    }

}

public struct Speed: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .metersPerSecond }
}
extension Speed {
    public static var metersPerSecond: Self {
        Self(symbol: "m/s", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var kilometersPerHour: Self {
        Self(symbol: "km/h", converter: UnitConverterLinear(coefficient: 0.277778))
    }
    public static var milesPerHour: Self {
        Self(symbol: "mph", converter: UnitConverterLinear(coefficient: 0.44704))
    }
    public static var knots: Self {
        Self(symbol: "kn", converter: UnitConverterLinear(coefficient: 0.514444))
    }
}
extension Measurement where UnitType == Speed {
    /// ```swift
    /// let acceleration = Measurement<Speed>.metersPerSecond(3).perSecond()
    /// ```
    public func perSecond() -> Measurement<Acceleration> {
        Measurement<Acceleration>(value: metersPerSecond, unit: .metersPerSecondSquared)
    }
    
    public var metersPerSecond: Double {
    value(in: .metersPerSecond)
}
    
    public static func metersPerSecond(_ value: Double) -> Self {
        Self(value, .metersPerSecond)
    }

    public static func kilometersPerHour(_ value: Double) -> Self {
        Self(value, .kilometersPerHour)
    }

    public var kilometersPerHour: Double {
        UnitType.convert(value, from: unit, to: .kilometersPerHour)
    }

    public static func milesPerHour(_ value: Double) -> Self {
        Self(value, .milesPerHour)
    }

    public var milesPerHour: Double {
        UnitType.convert(value, from: unit, to: .milesPerHour)
    }

    public static func knots(_ value: Double) -> Self {
        Self(value, .knots)
    }

    public var knots: Double {
        UnitType.convert(value, from: unit, to: .knots)
    }

}

public struct Energy: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .joules }
}
extension Energy {
    public static var joules: Self {
        Self(symbol: "J", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var kilojoules: Self {
        Self(symbol: "kJ", converter: UnitConverterLinear(coefficient: 1000.0))
    }
    public static var kilocalories: Self {
        Self(symbol: "kCal", converter: UnitConverterLinear(coefficient: 4184.0))
    }
    public static var calories: Self {
        Self(symbol: "cal", converter: UnitConverterLinear(coefficient: 4.184))
    }
    public static var kilowattHours: Self {
        Self(symbol: "kWh", converter: UnitConverterLinear(coefficient: 3600000.0))
    }
}
extension Measurement where UnitType == Energy {
    public var joules: Double {
    value(in: .joules)
}
    public static func joules(_ value: Double) -> Self {
        Self(value, .joules)
    }

    public static func kilojoules(_ value: Double) -> Self {
        Self(value, .kilojoules)
    }

    public var kilojoules: Double {
        UnitType.convert(value, from: unit, to: .kilojoules)
    }

    public static func kilocalories(_ value: Double) -> Self {
        Self(value, .kilocalories)
    }

    public var kilocalories: Double {
        UnitType.convert(value, from: unit, to: .kilocalories)
    }

    public static func calories(_ value: Double) -> Self {
        Self(value, .calories)
    }

    public var calories: Double {
        UnitType.convert(value, from: unit, to: .calories)
    }

    public static func kilowattHours(_ value: Double) -> Self {
        Self(value, .kilowattHours)
    }

    public var kilowattHours: Double {
        UnitType.convert(value, from: unit, to: .kilowattHours)
    }

}

public struct Power: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .watts }
}
extension Power {
    public static var watts: Self {
        Self(symbol: "W", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var terawatts: Self {
        Self(symbol: "TW", converter: UnitConverterLinear(coefficient: 1e12))
    }
    public static var gigawatts: Self {
        Self(symbol: "GW", converter: UnitConverterLinear(coefficient: 1e9))
    }
    public static var megawatts: Self {
        Self(symbol: "MW", converter: UnitConverterLinear(coefficient: 1000000.0))
    }
    public static var kilowatts: Self {
        Self(symbol: "kW", converter: UnitConverterLinear(coefficient: 1000.0))
    }
    public static var milliwatts: Self {
        Self(symbol: "mW", converter: UnitConverterLinear(coefficient: 0.001))
    }
    public static var microwatts: Self {
        Self(symbol: "µW", converter: UnitConverterLinear(coefficient: 0.000001))
    }
    public static var nanowatts: Self {
        Self(symbol: "nW", converter: UnitConverterLinear(coefficient: 1e-9))
    }
    public static var picowatts: Self {
        Self(symbol: "pW", converter: UnitConverterLinear(coefficient: 1e-12))
    }
    public static var femtowatts: Self {
        Self(symbol: "fW", converter: UnitConverterLinear(coefficient: 1e-15))
    }
    public static var horsepower: Self {
        Self(symbol: "hp", converter: UnitConverterLinear(coefficient: 745.7))
    }
}
extension Measurement where UnitType == Power {
    public var watts: Double {
    value(in: .watts)
}
    public static func watts(_ value: Double) -> Self {
        Self(value, .watts)
    }

    public static func terawatts(_ value: Double) -> Self {
        Self(value, .terawatts)
    }

    public var terawatts: Double {
        UnitType.convert(value, from: unit, to: .terawatts)
    }

    public static func gigawatts(_ value: Double) -> Self {
        Self(value, .gigawatts)
    }

    public var gigawatts: Double {
        UnitType.convert(value, from: unit, to: .gigawatts)
    }

    public static func megawatts(_ value: Double) -> Self {
        Self(value, .megawatts)
    }

    public var megawatts: Double {
        UnitType.convert(value, from: unit, to: .megawatts)
    }

    public static func kilowatts(_ value: Double) -> Self {
        Self(value, .kilowatts)
    }

    public var kilowatts: Double {
        UnitType.convert(value, from: unit, to: .kilowatts)
    }

    public static func milliwatts(_ value: Double) -> Self {
        Self(value, .milliwatts)
    }

    public var milliwatts: Double {
        UnitType.convert(value, from: unit, to: .milliwatts)
    }

    public static func microwatts(_ value: Double) -> Self {
        Self(value, .microwatts)
    }

    public var microwatts: Double {
        UnitType.convert(value, from: unit, to: .microwatts)
    }

    public static func nanowatts(_ value: Double) -> Self {
        Self(value, .nanowatts)
    }

    public var nanowatts: Double {
        UnitType.convert(value, from: unit, to: .nanowatts)
    }

    public static func picowatts(_ value: Double) -> Self {
        Self(value, .picowatts)
    }

    public var picowatts: Double {
        UnitType.convert(value, from: unit, to: .picowatts)
    }

    public static func femtowatts(_ value: Double) -> Self {
        Self(value, .femtowatts)
    }

    public var femtowatts: Double {
        UnitType.convert(value, from: unit, to: .femtowatts)
    }

    public static func horsepower(_ value: Double) -> Self {
        Self(value, .horsepower)
    }

    public var horsepower: Double {
        UnitType.convert(value, from: unit, to: .horsepower)
    }

}

public struct Temperature: Dimension, Hashable, Codable {
    public var symbol: String
    public var converter: UnitConverterLinear
    
    public static var kelvin: Self {
        Self(symbol: "K", converter: UnitConverterLinear(coefficient: 1, constant: 0))
    }
    
    public static var celsius: Self {
        Self(symbol: "°C", converter: UnitConverterLinear(coefficient: 1.0, constant: 273.15))
    }
    
    public static var fahrenheit: Self {
        Self(symbol: "°F", converter: UnitConverterLinear(coefficient: 0.55555555555556, constant: 255.37222222222427))
    }
    
    public init(symbol: String, converter: UnitConverterLinear) {
        self.symbol = symbol
        self.converter = converter
    }
    
    public static var base: Temperature { .kelvin }
}
extension Measurement where UnitType == Temperature {
    public var celsius: Double {
    value(in: .celsius)
}
    public static func celsius(_ value: Double) -> Self {
        Self(value, .celsius)
    }

    public static func kelvin(_ value: Double) -> Self {
        Self(value, .kelvin)
    }

    public var kelvin: Double {
        UnitType.convert(value, from: unit, to: .kelvin)
    }

    public static func fahrenheit(_ value: Double) -> Self {
        Self(value, .fahrenheit)
    }

    public var fahrenheit: Double {
        UnitType.convert(value, from: unit, to: .fahrenheit)
    }

}

public struct Illuminance: Dimension, Hashable, Codable {
    public init(symbol: String, converter: UnitConverterLinear) {
        self.converter = converter
        self.symbol = symbol
    }
    
    public var converter: UnitConverterLinear
    public var symbol: String
    
    public static var lux: Self { Self(symbol: "lx", converter: Converter(coefficient: 1))}
    public static var base: Self { .lux }
}
public extension Measurement where UnitType == Illuminance {
    var lux: Double {
        value
    }
    
    init(lux: Double) {
        self.init(lux, .lux)
    }
    
    static func lux(_ lux: Double) -> Self {
        self.init(lux: lux)
    }
}

public struct ElectricCharge: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .coulombs }
}
extension ElectricCharge {
    public static var coulombs: Self {
        Self(symbol: "C", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var megaampereHours: Self {
        Self(symbol: "MAh", converter: UnitConverterLinear(coefficient: 3.6e9))
    }
    public static var kiloampereHours: Self {
        Self(symbol: "kAh", converter: UnitConverterLinear(coefficient: 3600000.0))
    }
    public static var ampereHours: Self {
        Self(symbol: "Ah", converter: UnitConverterLinear(coefficient: 3600.0))
    }
    public static var milliampereHours: Self {
        Self(symbol: "mAh", converter: UnitConverterLinear(coefficient: 3.6))
    }
    public static var microampereHours: Self {
        Self(symbol: "µAh", converter: UnitConverterLinear(coefficient: 0.0036))
    }
}
extension Measurement where UnitType == ElectricCharge {
    public var coulombs: Double {
    value(in: .coulombs)
}
    public static func coulombs(_ value: Double) -> Self {
        Self(value, .coulombs)
    }

    public static func megaampereHours(_ value: Double) -> Self {
        Self(value, .megaampereHours)
    }

    public var megaampereHours: Double {
        UnitType.convert(value, from: unit, to: .megaampereHours)
    }

    public static func kiloampereHours(_ value: Double) -> Self {
        Self(value, .kiloampereHours)
    }

    public var kiloampereHours: Double {
        UnitType.convert(value, from: unit, to: .kiloampereHours)
    }

    public static func ampereHours(_ value: Double) -> Self {
        Self(value, .ampereHours)
    }

    public var ampereHours: Double {
        UnitType.convert(value, from: unit, to: .ampereHours)
    }

    public static func milliampereHours(_ value: Double) -> Self {
        Self(value, .milliampereHours)
    }

    public var milliampereHours: Double {
        UnitType.convert(value, from: unit, to: .milliampereHours)
    }

    public static func microampereHours(_ value: Double) -> Self {
        Self(value, .microampereHours)
    }

    public var microampereHours: Double {
        UnitType.convert(value, from: unit, to: .microampereHours)
    }

}

public struct ElectricCurrent: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .coulombs }
}
extension ElectricCurrent {
    public static var coulombs: Self {
        Self(symbol: "C", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var megaampereHours: Self {
        Self(symbol: "MAh", converter: UnitConverterLinear(coefficient: 3.6e9))
    }
    public static var kiloampereHours: Self {
        Self(symbol: "kAh", converter: UnitConverterLinear(coefficient: 3600000.0))
    }
    public static var ampereHours: Self {
        Self(symbol: "Ah", converter: UnitConverterLinear(coefficient: 3600.0))
    }
    public static var milliampereHours: Self {
        Self(symbol: "mAh", converter: UnitConverterLinear(coefficient: 3.6))
    }
    public static var microampereHours: Self {
        Self(symbol: "µAh", converter: UnitConverterLinear(coefficient: 0.0036))
    }
}
extension Measurement where UnitType == ElectricCurrent {
    public var coulombs: Double {
    value(in: .coulombs)
}
    public static func coulombs(_ value: Double) -> Self {
        Self(value, .coulombs)
    }

    public static func megaampereHours(_ value: Double) -> Self {
        Self(value, .megaampereHours)
    }

    public var megaampereHours: Double {
        UnitType.convert(value, from: unit, to: .megaampereHours)
    }

    public static func kiloampereHours(_ value: Double) -> Self {
        Self(value, .kiloampereHours)
    }

    public var kiloampereHours: Double {
        UnitType.convert(value, from: unit, to: .kiloampereHours)
    }

    public static func ampereHours(_ value: Double) -> Self {
        Self(value, .ampereHours)
    }

    public var ampereHours: Double {
        UnitType.convert(value, from: unit, to: .ampereHours)
    }

    public static func milliampereHours(_ value: Double) -> Self {
        Self(value, .milliampereHours)
    }

    public var milliampereHours: Double {
        UnitType.convert(value, from: unit, to: .milliampereHours)
    }

    public static func microampereHours(_ value: Double) -> Self {
        Self(value, .microampereHours)
    }

    public var microampereHours: Double {
        UnitType.convert(value, from: unit, to: .microampereHours)
    }

}

public struct ElectricPotentialDifference: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .volts }
}
extension ElectricPotentialDifference {
    public static var volts: Self {
        Self(symbol: "V", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var megavolts: Self {
        Self(symbol: "MV", converter: UnitConverterLinear(coefficient: 1000000.0))
    }
    public static var kilovolts: Self {
        Self(symbol: "kV", converter: UnitConverterLinear(coefficient: 1000.0))
    }
    public static var millivolts: Self {
        Self(symbol: "mV", converter: UnitConverterLinear(coefficient: 0.001))
    }
    public static var microvolts: Self {
        Self(symbol: "µV", converter: UnitConverterLinear(coefficient: 0.000001))
    }
}
extension Measurement where UnitType == ElectricPotentialDifference {
    public var volts: Double {
    value(in: .volts)
}
    public static func volts(_ value: Double) -> Self {
        Self(value, .volts)
    }

    public static func megavolts(_ value: Double) -> Self {
        Self(value, .megavolts)
    }

    public var megavolts: Double {
        UnitType.convert(value, from: unit, to: .megavolts)
    }

    public static func kilovolts(_ value: Double) -> Self {
        Self(value, .kilovolts)
    }

    public var kilovolts: Double {
        UnitType.convert(value, from: unit, to: .kilovolts)
    }

    public static func millivolts(_ value: Double) -> Self {
        Self(value, .millivolts)
    }

    public var millivolts: Double {
        UnitType.convert(value, from: unit, to: .millivolts)
    }

    public static func microvolts(_ value: Double) -> Self {
        Self(value, .microvolts)
    }

    public var microvolts: Double {
        UnitType.convert(value, from: unit, to: .microvolts)
    }

}

public struct ElectricResistance: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .ohms }
}
extension ElectricResistance {
    public static var ohms: Self {
        Self(symbol: "Ω", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var megaohms: Self {
        Self(symbol: "MΩ", converter: UnitConverterLinear(coefficient: 1000000.0))
    }
    public static var kiloohms: Self {
        Self(symbol: "kΩ", converter: UnitConverterLinear(coefficient: 1000.0))
    }
    public static var milliohms: Self {
        Self(symbol: "mΩ", converter: UnitConverterLinear(coefficient: 0.001))
    }
    public static var microohms: Self {
        Self(symbol: "µΩ", converter: UnitConverterLinear(coefficient: 0.000001))
    }
}
extension Measurement where UnitType == ElectricResistance {
    public var ohms: Double {
    value(in: .ohms)
}
    public static func ohms(_ value: Double) -> Self {
        Self(value, .ohms)
    }

    public static func megaohms(_ value: Double) -> Self {
        Self(value, .megaohms)
    }

    public var megaohms: Double {
        UnitType.convert(value, from: unit, to: .megaohms)
    }

    public static func kiloohms(_ value: Double) -> Self {
        Self(value, .kiloohms)
    }

    public var kiloohms: Double {
        UnitType.convert(value, from: unit, to: .kiloohms)
    }

    public static func milliohms(_ value: Double) -> Self {
        Self(value, .milliohms)
    }

    public var milliohms: Double {
        UnitType.convert(value, from: unit, to: .milliohms)
    }

    public static func microohms(_ value: Double) -> Self {
        Self(value, .microohms)
    }

    public var microohms: Double {
        UnitType.convert(value, from: unit, to: .microohms)
    }

}

public struct ConcentrationOfMass: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .gramsPerLiter }
}
extension ConcentrationOfMass {
    public static var gramsPerLiter: Self {
        Self(symbol: "g/L", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var milligramsPerDeciliter: Self {
        Self(symbol: "mg/dL", converter: UnitConverterLinear(coefficient: 0.01))
    }
    
    public static func millimolesPerLiter(gramsPerMole: Double) -> Self {
        Self(symbol: "mmol/L", converter: UnitConverterLinear(coefficient: 18 * gramsPerMole))
    }
}
extension Measurement where UnitType == ConcentrationOfMass {
    public var gramsPerLiter: Double {
    value(in: .gramsPerLiter)
}
    public static func gramsPerLiter(_ value: Double) -> Self {
        Self(value, .gramsPerLiter)
    }

    public static func milligramsPerDeciliter(_ value: Double) -> Self {
        Self(value, .milligramsPerDeciliter)
    }

    public var milligramsPerDeciliter: Double {
        UnitType.convert(value, from: unit, to: .milligramsPerDeciliter)
    }

    public static func millimolesPerLiter(_ value: Double, gramsPerMole: Double) -> Self {
        Self(value, .millimolesPerLiter(gramsPerMole: gramsPerMole))
    }
    
    public func millimolesPerLiter(gramsPerMole: Double) -> Double {
        self.value(in: .millimolesPerLiter(gramsPerMole: gramsPerMole))
    }
}

public struct Dispersion: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .partsPerMillion }
}
extension Dispersion {
    public static var partsPerMillion: Self {
        Self(symbol: "ppm", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var partsPerBillion: Self {
        Self(symbol: "ppb", converter: UnitConverterLinear(coefficient: 0.001))
    }
}
extension Measurement where UnitType == Dispersion {
    public var partsPerMillion: Double {
    value(in: .partsPerMillion)
}
    public static func partsPerMillion(_ value: Double) -> Self {
        Self(value, .partsPerMillion)
    }

    public static func partsPerBillion(_ value: Double) -> Self {
        Self(value, .partsPerBillion)
    }

    public var partsPerBillion: Double {
        UnitType.convert(value, from: unit, to: .partsPerBillion)
    }

}

public struct FuelEfficiency: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterReciprocal
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: Converter
    public let symbol: String
    
    public static var litersPer100Kilometers: Self {
        Self(symbol: "L/100km", converter: Converter(reciprocal: 0))
    }
    
    public static var milesPerGallon: Self {
        Self(symbol: "mpg", converter: Converter(reciprocal: 235.215000))
    }
    
    public static var milesPerImperialGallon: Self {
        Self(symbol: "mpg", converter: Converter(reciprocal: 282.481000))
    }
    
    public static var base: Self { .litersPer100Kilometers }
}
extension Measurement where UnitType == FuelEfficiency {
    public var litersPer100Kilometers: Double {
    value(in: .litersPer100Kilometers)
}
    public static func litersPer100Kilometers(_ value: Double) -> Self {
        Self(value, .litersPer100Kilometers)
    }

    public static func milesPerGallon(_ value: Double) -> Self {
        Self(value, .milesPerGallon)
    }

    public var milesPerGallon: Double {
        UnitType.convert(value, from: unit, to: .milesPerGallon)
    }

    public static func milesPerImperialGallon(_ value: Double) -> Self {
        Self(value, .milesPerImperialGallon)
    }

    public var milesPerImperialGallon: Double {
        UnitType.convert(value, from: unit, to: .milesPerImperialGallon)
    }

}

public struct InformationStorage: Dimension, Hashable, Codable {
    public typealias Converter = UnitConverterLinear
    public init(symbol: String, converter: Converter) {
        self.symbol = symbol
        self.converter = converter
    }


    public var converter: UnitConverterLinear
    public let symbol: String
    public static var base: Self { .bits }
}
extension InformationStorage {
    public static var bits: Self {
        Self(symbol: "bits", converter: UnitConverterLinear(coefficient: 1))
    }

    public static var nibbles: Self {
        Self(symbol: "nibbles", converter: UnitConverterLinear(coefficient: 4))
    }
    public static var bytes: Self {
        Self(symbol: "B", converter: UnitConverterLinear(coefficient: 8))
    }
    public static var kilobits: Self {
        Self(symbol: "Kb", converter: UnitConverterLinear(coefficient: 1000))
    }
    public static var kibibits: Self {
        Self(symbol: "Kib", converter: UnitConverterLinear(coefficient: 1024))
    }
    public static var megabits: Self {
        Self(symbol: "Mb", converter: UnitConverterLinear(coefficient: 1000e2))
    }
    public static var mebibits: Self {
        Self(symbol: "Mib", converter: UnitConverterLinear(coefficient: 1024e2))
    }
    public static var gigabits: Self {
        Self(symbol: "Gb", converter: UnitConverterLinear(coefficient: 1000e3))
    }
    public static var gibibits: Self {
        Self(symbol: "Gib", converter: UnitConverterLinear(coefficient: 1024e3))
    }
    public static var terabits: Self {
        Self(symbol: "Tb", converter: UnitConverterLinear(coefficient: 1000e4))
    }
    public static var tebibits: Self {
        Self(symbol: "Tib", converter: UnitConverterLinear(coefficient: 1024e4))
    }
    public static var petabits: Self {
        Self(symbol: "Pb", converter: UnitConverterLinear(coefficient: 1000e5))
    }
    public static var pebibits: Self {
        Self(symbol: "Pib", converter: UnitConverterLinear(coefficient: 1024e5))
    }
    public static var exabits: Self {
        Self(symbol: "Eb", converter: UnitConverterLinear(coefficient: 1000e6))
    }
    public static var exbibits: Self {
        Self(symbol: "Eib", converter: UnitConverterLinear(coefficient: 1024e6))
    }
    public static var zettabits: Self {
        Self(symbol: "Zb", converter: UnitConverterLinear(coefficient: 1000e7))
    }
    public static var zebibits: Self {
        Self(symbol: "Zib", converter: UnitConverterLinear(coefficient: 1024e7))
    }
    public static var yottabits: Self {
        Self(symbol: "Yb", converter: UnitConverterLinear(coefficient: 1000e8))
    }
    public static var yobibits: Self {
        Self(symbol: "Yib", converter: UnitConverterLinear(coefficient: 1024e8))
    }
    public static var kilobytes: Self {
        Self(symbol: "KB", converter: UnitConverterLinear(coefficient: 1000))
    }
    public static var kibibytes: Self {
        Self(symbol: "KiB", converter: UnitConverterLinear(coefficient: 1024))
    }
    public static var megabytes: Self {
        Self(symbol: "MB", converter: UnitConverterLinear(coefficient: 1000e2))
    }
    public static var mebibytes: Self {
        Self(symbol: "MiB", converter: UnitConverterLinear(coefficient: 1024e2))
    }
    public static var gigabytes: Self {
        Self(symbol: "GB", converter: UnitConverterLinear(coefficient: 1000e3))
    }
    public static var gibibytes: Self {
        Self(symbol: "GiB", converter: UnitConverterLinear(coefficient: 1024e3))
    }
    public static var terabytes: Self {
        Self(symbol: "TB", converter: UnitConverterLinear(coefficient: 1000e4))
    }
    public static var tebibytes: Self {
        Self(symbol: "TiB", converter: UnitConverterLinear(coefficient: 1024e4))
    }
    public static var petabytes: Self {
        Self(symbol: "PB", converter: UnitConverterLinear(coefficient: 1000e5))
    }
    public static var pebibytes: Self {
        Self(symbol: "PiB", converter: UnitConverterLinear(coefficient: 1024e5))
    }
    public static var exabytes: Self {
        Self(symbol: "EB", converter: UnitConverterLinear(coefficient: 1000e6))
    }
    public static var exbibytes: Self {
        Self(symbol: "EiB", converter: UnitConverterLinear(coefficient: 1024e6))
    }
    public static var zettabytes: Self {
        Self(symbol: "ZB", converter: UnitConverterLinear(coefficient: 1000e7))
    }
    public static var zebibytes: Self {
        Self(symbol: "ZiB", converter: UnitConverterLinear(coefficient: 1024e7))
    }
    public static var yottabytes: Self {
        Self(symbol: "YB", converter: UnitConverterLinear(coefficient: 1000e8))
    }
    public static var yobibytes: Self {
        Self(symbol: "YiB", converter: UnitConverterLinear(coefficient: 1024e8))
    }
}

extension Measurement where UnitType == InformationStorage {
    public var bits: Double {
    value(in: .bits)
}
    public static func bits(_ value: Double) -> Self {
        Self(value, .bits)
    }

    public static func nibbles(_ value: Double) -> Self {
        Self(value, .nibbles)
    }

    public var nibbles: Double {
        UnitType.convert(value, from: unit, to: .nibbles)
    }

    public static func bytes(_ value: Double) -> Self {
        Self(value, .bytes)
    }

    public var bytes: Double {
        UnitType.convert(value, from: unit, to: .bytes)
    }

    public static func kilobits(_ value: Double) -> Self {
        Self(value, .kilobits)
    }

    public var kilobits: Double {
        UnitType.convert(value, from: unit, to: .kilobits)
    }

    public static func kibibits(_ value: Double) -> Self {
        Self(value, .kibibits)
    }

    public var kibibits: Double {
        UnitType.convert(value, from: unit, to: .kibibits)
    }

    public static func megabits(_ value: Double) -> Self {
        Self(value, .megabits)
    }

    public var megabits: Double {
        UnitType.convert(value, from: unit, to: .megabits)
    }

    public static func mebibits(_ value: Double) -> Self {
        Self(value, .mebibits)
    }

    public var mebibits: Double {
        UnitType.convert(value, from: unit, to: .mebibits)
    }

    public static func gigabits(_ value: Double) -> Self {
        Self(value, .gigabits)
    }

    public var gigabits: Double {
        UnitType.convert(value, from: unit, to: .gigabits)
    }

    public static func gibibits(_ value: Double) -> Self {
        Self(value, .gibibits)
    }

    public var gibibits: Double {
        UnitType.convert(value, from: unit, to: .gibibits)
    }

    public static func terabits(_ value: Double) -> Self {
        Self(value, .terabits)
    }

    public var terabits: Double {
        UnitType.convert(value, from: unit, to: .terabits)
    }

    public static func tebibits(_ value: Double) -> Self {
        Self(value, .tebibits)
    }

    public var tebibits: Double {
        UnitType.convert(value, from: unit, to: .tebibits)
    }

    public static func petabits(_ value: Double) -> Self {
        Self(value, .petabits)
    }

    public var petabits: Double {
        UnitType.convert(value, from: unit, to: .petabits)
    }

    public static func pebibits(_ value: Double) -> Self {
        Self(value, .pebibits)
    }

    public var pebibits: Double {
        UnitType.convert(value, from: unit, to: .pebibits)
    }

    public static func exabits(_ value: Double) -> Self {
        Self(value, .exabits)
    }

    public var exabits: Double {
        UnitType.convert(value, from: unit, to: .exabits)
    }

    public static func exbibits(_ value: Double) -> Self {
        Self(value, .exbibits)
    }

    public var exbibits: Double {
        UnitType.convert(value, from: unit, to: .exbibits)
    }

    public static func zettabits(_ value: Double) -> Self {
        Self(value, .zettabits)
    }

    public var zettabits: Double {
        UnitType.convert(value, from: unit, to: .zettabits)
    }

    public static func zebibits(_ value: Double) -> Self {
        Self(value, .zebibits)
    }

    public var zebibits: Double {
        UnitType.convert(value, from: unit, to: .zebibits)
    }

    public static func yottabits(_ value: Double) -> Self {
        Self(value, .yottabits)
    }

    public var yottabits: Double {
        UnitType.convert(value, from: unit, to: .yottabits)
    }

    public static func yobibits(_ value: Double) -> Self {
        Self(value, .yobibits)
    }

    public var yobibits: Double {
        UnitType.convert(value, from: unit, to: .yobibits)
    }

    public static func kilobytes(_ value: Double) -> Self {
        Self(value, .kilobytes)
    }

    public var kilobytes: Double {
        UnitType.convert(value, from: unit, to: .kilobytes)
    }

    public static func kibibytes(_ value: Double) -> Self {
        Self(value, .kibibytes)
    }

    public var kibibytes: Double {
        UnitType.convert(value, from: unit, to: .kibibytes)
    }

    public static func megabytes(_ value: Double) -> Self {
        Self(value, .megabytes)
    }

    public var megabytes: Double {
        UnitType.convert(value, from: unit, to: .megabytes)
    }

    public static func mebibytes(_ value: Double) -> Self {
        Self(value, .mebibytes)
    }

    public var mebibytes: Double {
        UnitType.convert(value, from: unit, to: .mebibytes)
    }

    public static func gigabytes(_ value: Double) -> Self {
        Self(value, .gigabytes)
    }

    public var gigabytes: Double {
        UnitType.convert(value, from: unit, to: .gigabytes)
    }

    public static func gibibytes(_ value: Double) -> Self {
        Self(value, .gibibytes)
    }

    public var gibibytes: Double {
        UnitType.convert(value, from: unit, to: .gibibytes)
    }

    public static func terabytes(_ value: Double) -> Self {
        Self(value, .terabytes)
    }

    public var terabytes: Double {
        UnitType.convert(value, from: unit, to: .terabytes)
    }

    public static func tebibytes(_ value: Double) -> Self {
        Self(value, .tebibytes)
    }

    public var tebibytes: Double {
        UnitType.convert(value, from: unit, to: .tebibytes)
    }

    public static func petabytes(_ value: Double) -> Self {
        Self(value, .petabytes)
    }

    public var petabytes: Double {
        UnitType.convert(value, from: unit, to: .petabytes)
    }

    public static func pebibytes(_ value: Double) -> Self {
        Self(value, .pebibytes)
    }

    public var pebibytes: Double {
        UnitType.convert(value, from: unit, to: .pebibytes)
    }

    public static func exabytes(_ value: Double) -> Self {
        Self(value, .exabytes)
    }

    public var exabytes: Double {
        UnitType.convert(value, from: unit, to: .exabytes)
    }

    public static func exbibytes(_ value: Double) -> Self {
        Self(value, .exbibytes)
    }

    public var exbibytes: Double {
        UnitType.convert(value, from: unit, to: .exbibytes)
    }

    public static func zettabytes(_ value: Double) -> Self {
        Self(value, .zettabytes)
    }

    public var zettabytes: Double {
        UnitType.convert(value, from: unit, to: .zettabytes)
    }

    public static func zebibytes(_ value: Double) -> Self {
        Self(value, .zebibytes)
    }

    public var zebibytes: Double {
        UnitType.convert(value, from: unit, to: .zebibytes)
    }

    public static func yottabytes(_ value: Double) -> Self {
        Self(value, .yottabytes)
    }

    public var yottabytes: Double {
        UnitType.convert(value, from: unit, to: .yottabytes)
    }

    public static func yobibytes(_ value: Double) -> Self {
        Self(value, .yobibytes)
    }

    public var yobibytes: Double {
        UnitType.convert(value, from: unit, to: .yobibytes)
    }

}
