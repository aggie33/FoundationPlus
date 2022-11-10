import Foundation

/// A unit of measurement.
public protocol UnitProtocol {
    /// The base unit.
    static var base: Self { get }
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

/// A measurement that measures length. Allows you to convert between various units of length, and offers convenient shorthand!
/// ```swift
/// let height: Length = .feet(5) + .inches(7)
/// print(height.centimeters)
/// ```
///
///
///
///

/// Measures the distance between two points in space.
public struct Length: Measurement {
    public enum Unit: Double, DimensionProtocol {
        case megameters = 1e6
        case kilometers = 1e3
        case hectometers = 1e2
        case decameters = 1e1
        case meters = 1e0
        case decimeters = 1e-1
        case centimeters = 1e-2
        case millimeters = 1e-3
        case micrometers = 1e-6
        case nanometers = 1e-9
        case picometers = 1e-12
        case inches = 0.0254
        case feet = 0.3048
        case yards = 0.9144
        case miles = 1609.34
        case scandinavianMiles = 10000
        case lightyears = 9.461e15
        case nauticalMiles = 1852
        case fathoms = 1.8288
        case furlongs = 201.168
        case astronomicalUnits = 1.496e11
        case parsecs = 3.086e16
        
        public static var base: Self { .meters }
        
        public var conversionFactor: Double { rawValue }
    }
    
    @_implements(Measurement, valueInBaseUnit)
    public var meters: Double
    
    public func value(in unit: Unit) -> Double {
        meters / unit.rawValue
    }
    
    public init(meters: Double) {
        self.meters = meters
    }
    
    public init(valueInBaseUnit: Double) {
        self.meters = valueInBaseUnit
    }
    
    public init(_ value: Double, _ unit: Unit) {
        self.init(meters: value * unit.rawValue)
    }
}

extension Length {
    public init<T: BinaryFloatingPoint>(_ value: T, _ unit: Unit) {
        self.init(meters: Double(value) * unit.rawValue)
    }
    
    public init<T: BinaryInteger>(_ value: T, _ unit: Unit) {
        self.init(meters: Double(value) * unit.rawValue)
    }
    
    public static func megameters<T: BinaryFloatingPoint>(_ megameters: T) -> Self {
        Self(megameters, .megameters)
    }
    
    public static func megameters<T: BinaryInteger>(_ megameters: T) -> Self {
        Self(megameters, .megameters)
    }
    
    public init<T: BinaryFloatingPoint>(megameters: T) {
        self.init(megameters, .megameters)
    }
    
    public init<T: BinaryInteger>(megameters: T) {
        self.init(megameters, .megameters)
    }
    
    public var megameters: Double {
        get { value(in: .megameters) }
    }
    
    public static func kilometers<T: BinaryFloatingPoint>(_ kilometers: T) -> Self {
        Self(kilometers, .kilometers)
    }
    
    public static func kilometers<T: BinaryInteger>(_ kilometers: T) -> Self {
        Self(kilometers, .kilometers)
    }
    
    public init<T: BinaryFloatingPoint>(kilometers: T) {
        self.init(kilometers, .kilometers)
    }
    
    public init<T: BinaryInteger>(kilometers: T) {
        self.init(kilometers, .kilometers)
    }
    
    public var kilometers: Double {
        get { value(in: .kilometers) }
    }
    
    public static func hectometers<T: BinaryFloatingPoint>(_ hectometers: T) -> Self {
        Self(hectometers, .hectometers)
    }
    
    public static func hectometers<T: BinaryInteger>(_ hectometers: T) -> Self {
        Self(hectometers, .hectometers)
    }
    
    public init<T: BinaryFloatingPoint>(hectometers: T) {
        self.init(hectometers, .hectometers)
    }
    
    public init<T: BinaryInteger>(hectometers: T) {
        self.init(hectometers, .hectometers)
    }
    
    public var hectometers: Double {
        get { value(in: .hectometers) }
    }
    
    public static func decameters<T: BinaryFloatingPoint>(_ decameters: T) -> Self {
        Self(decameters, .decameters)
    }
    
    public static func decameters<T: BinaryInteger>(_ decameters: T) -> Self {
        Self(decameters, .decameters)
    }
    
    public init<T: BinaryFloatingPoint>(decameters: T) {
        self.init(decameters, .decameters)
    }
    
    public init<T: BinaryInteger>(decameters: T) {
        self.init(decameters, .decameters)
    }
    
    public var decameters: Double {
        get { value(in: .decameters) }
    }
    
    public static func meters<T: BinaryFloatingPoint>(_ meters: T) -> Self {
        Self(meters, .meters)
    }
    
    public static func meters<T: BinaryInteger>(_ meters: T) -> Self {
        Self(meters, .meters)
    }
    
    public init<T: BinaryFloatingPoint>(meters: T) {
        self.init(meters, .meters)
    }
    
    public init<T: BinaryInteger>(meters: T) {
        self.init(meters, .meters)
    }
    
    public static func decimeters<T: BinaryFloatingPoint>(_ decimeters: T) -> Self {
        Self(decimeters, .decimeters)
    }
    
    public static func decimeters<T: BinaryInteger>(_ decimeters: T) -> Self {
        Self(decimeters, .decimeters)
    }
    
    public init<T: BinaryFloatingPoint>(decimeters: T) {
        self.init(decimeters, .decimeters)
    }
    
    public init<T: BinaryInteger>(decimeters: T) {
        self.init(decimeters, .decimeters)
    }
    
    public var decimeters: Double {
        get { value(in: .decimeters) }
    }
    
    public static func centimeters<T: BinaryFloatingPoint>(_ centimeters: T) -> Self {
        Self(centimeters, .centimeters)
    }
    
    public static func centimeters<T: BinaryInteger>(_ centimeters: T) -> Self {
        Self(centimeters, .centimeters)
    }
    
    public init<T: BinaryFloatingPoint>(centimeters: T) {
        self.init(centimeters, .centimeters)
    }
    
    public init<T: BinaryInteger>(centimeters: T) {
        self.init(centimeters, .centimeters)
    }
    
    public var centimeters: Double {
        get { value(in: .centimeters) }
    }
    
    public static func millimeters<T: BinaryFloatingPoint>(_ millimeters: T) -> Self {
        Self(millimeters, .millimeters)
    }
    
    public static func millimeters<T: BinaryInteger>(_ millimeters: T) -> Self {
        Self(millimeters, .millimeters)
    }
    
    public init<T: BinaryFloatingPoint>(millimeters: T) {
        self.init(millimeters, .millimeters)
    }
    
    public init<T: BinaryInteger>(millimeters: T) {
        self.init(millimeters, .millimeters)
    }
    
    public var millimeters: Double {
        get { value(in: .millimeters) }
    }
    
    public static func micrometers<T: BinaryFloatingPoint>(_ micrometers: T) -> Self {
        Self(micrometers, .micrometers)
    }
    
    public static func micrometers<T: BinaryInteger>(_ micrometers: T) -> Self {
        Self(micrometers, .micrometers)
    }
    
    public init<T: BinaryFloatingPoint>(micrometers: T) {
        self.init(micrometers, .micrometers)
    }
    
    public init<T: BinaryInteger>(micrometers: T) {
        self.init(micrometers, .micrometers)
    }
    
    public var micrometers: Double {
        get { value(in: .micrometers) }
    }
    
    public static func nanometers<T: BinaryFloatingPoint>(_ nanometers: T) -> Self {
        Self(nanometers, .nanometers)
    }
    
    public static func nanometers<T: BinaryInteger>(_ nanometers: T) -> Self {
        Self(nanometers, .nanometers)
    }
    
    public init<T: BinaryFloatingPoint>(nanometers: T) {
        self.init(nanometers, .nanometers)
    }
    
    public init<T: BinaryInteger>(nanometers: T) {
        self.init(nanometers, .nanometers)
    }
    
    public var nanometers: Double {
        get { value(in: .nanometers) }
    }
    
    public static func picometers<T: BinaryFloatingPoint>(_ picometers: T) -> Self {
        Self(picometers, .picometers)
    }
    
    public static func picometers<T: BinaryInteger>(_ picometers: T) -> Self {
        Self(picometers, .picometers)
    }
    
    public init<T: BinaryFloatingPoint>(picometers: T) {
        self.init(picometers, .picometers)
    }
    
    public init<T: BinaryInteger>(picometers: T) {
        self.init(picometers, .picometers)
    }
    
    public var picometers: Double {
        get { value(in: .picometers) }
    }
    
    public static func inches<T: BinaryFloatingPoint>(_ inches: T) -> Self {
        Self(inches, .inches)
    }
    
    public static func inches<T: BinaryInteger>(_ inches: T) -> Self {
        Self(inches, .inches)
    }
    
    public init<T: BinaryFloatingPoint>(inches: T) {
        self.init(inches, .inches)
    }
    
    public init<T: BinaryInteger>(inches: T) {
        self.init(inches, .inches)
    }
    
    public var inches: Double {
        get { value(in: .inches) }
    }
    
    public static func feet<T: BinaryFloatingPoint>(_ feet: T) -> Self {
        Self(feet, .feet)
    }
    
    public static func feet<T: BinaryInteger>(_ feet: T) -> Self {
        Self(feet, .feet)
    }
    
    public init<T: BinaryFloatingPoint>(feet: T) {
        self.init(feet, .feet)
    }
    
    public init<T: BinaryInteger>(feet: T) {
        self.init(feet, .feet)
    }
    
    public var feet: Double {
        get { value(in: .feet) }
    }
    
    public static func yards<T: BinaryFloatingPoint>(_ yards: T) -> Self {
        Self(yards, .yards)
    }
    
    public static func yards<T: BinaryInteger>(_ yards: T) -> Self {
        Self(yards, .yards)
    }
    
    public init<T: BinaryFloatingPoint>(yards: T) {
        self.init(yards, .yards)
    }
    
    public init<T: BinaryInteger>(yards: T) {
        self.init(yards, .yards)
    }
    
    public var yards: Double {
        get { value(in: .yards) }
    }
    
    public static func miles<T: BinaryFloatingPoint>(_ miles: T) -> Self {
        Self(miles, .miles)
    }
    
    public static func miles<T: BinaryInteger>(_ miles: T) -> Self {
        Self(miles, .miles)
    }
    
    public init<T: BinaryFloatingPoint>(miles: T) {
        self.init(miles, .miles)
    }
    
    public init<T: BinaryInteger>(miles: T) {
        self.init(miles, .miles)
    }
    
    public var miles: Double {
        get { value(in: .miles) }
    }
    
    public static func scandinavianMiles<T: BinaryFloatingPoint>(_ scandinavianMiles: T) -> Self {
        Self(scandinavianMiles, .scandinavianMiles)
    }
    
    public static func scandinavianMiles<T: BinaryInteger>(_ scandinavianMiles: T) -> Self {
        Self(scandinavianMiles, .scandinavianMiles)
    }
    
    public init<T: BinaryFloatingPoint>(scandinavianMiles: T) {
        self.init(scandinavianMiles, .scandinavianMiles)
    }
    
    public init<T: BinaryInteger>(scandinavianMiles: T) {
        self.init(scandinavianMiles, .scandinavianMiles)
    }
    
    public var scandinavianMiles: Double {
        get { value(in: .scandinavianMiles) }
    }
    
    public static func lightyears<T: BinaryFloatingPoint>(_ lightyears: T) -> Self {
        Self(lightyears, .lightyears)
    }
    
    public static func lightyears<T: BinaryInteger>(_ lightyears: T) -> Self {
        Self(lightyears, .lightyears)
    }
    
    public init<T: BinaryFloatingPoint>(lightyears: T) {
        self.init(lightyears, .lightyears)
    }
    
    public init<T: BinaryInteger>(lightyears: T) {
        self.init(lightyears, .lightyears)
    }
    
    public var lightyears: Double {
        get { value(in: .lightyears) }
    }
    
    public static func nauticalMiles<T: BinaryFloatingPoint>(_ nauticalMiles: T) -> Self {
        Self(nauticalMiles, .nauticalMiles)
    }
    
    public static func nauticalMiles<T: BinaryInteger>(_ nauticalMiles: T) -> Self {
        Self(nauticalMiles, .nauticalMiles)
    }
    
    public init<T: BinaryFloatingPoint>(nauticalMiles: T) {
        self.init(nauticalMiles, .nauticalMiles)
    }
    
    public init<T: BinaryInteger>(nauticalMiles: T) {
        self.init(nauticalMiles, .nauticalMiles)
    }
    
    public var nauticalMiles: Double {
        get { value(in: .nauticalMiles) }
    }
    
    public static func fathoms<T: BinaryFloatingPoint>(_ fathoms: T) -> Self {
        Self(fathoms, .fathoms)
    }
    
    public static func fathoms<T: BinaryInteger>(_ fathoms: T) -> Self {
        Self(fathoms, .fathoms)
    }
    
    public init<T: BinaryFloatingPoint>(fathoms: T) {
        self.init(fathoms, .fathoms)
    }
    
    public init<T: BinaryInteger>(fathoms: T) {
        self.init(fathoms, .fathoms)
    }
    
    public var fathoms: Double {
        get { value(in: .fathoms) }
    }
    
    public static func furlongs<T: BinaryFloatingPoint>(_ furlongs: T) -> Self {
        Self(furlongs, .furlongs)
    }
    
    public static func furlongs<T: BinaryInteger>(_ furlongs: T) -> Self {
        Self(furlongs, .furlongs)
    }
    
    public init<T: BinaryFloatingPoint>(furlongs: T) {
        self.init(furlongs, .furlongs)
    }
    
    public init<T: BinaryInteger>(furlongs: T) {
        self.init(furlongs, .furlongs)
    }
    
    public var furlongs: Double {
        get { value(in: .furlongs) }
    }
    
    public static func astronomicalUnits<T: BinaryFloatingPoint>(_ astronomicalUnits: T) -> Self {
        Self(astronomicalUnits, .astronomicalUnits)
    }
    
    public static func astronomicalUnits<T: BinaryInteger>(_ astronomicalUnits: T) -> Self {
        Self(astronomicalUnits, .astronomicalUnits)
    }
    
    public init<T: BinaryFloatingPoint>(astronomicalUnits: T) {
        self.init(astronomicalUnits, .astronomicalUnits)
    }
    
    public init<T: BinaryInteger>(astronomicalUnits: T) {
        self.init(astronomicalUnits, .astronomicalUnits)
    }
    
    public var astronomicalUnits: Double {
        get { value(in: .astronomicalUnits) }
    }
    
    public static func parsecs<T: BinaryFloatingPoint>(_ parsecs: T) -> Self {
        Self(parsecs, .parsecs)
    }
    
    public static func parsecs<T: BinaryInteger>(_ parsecs: T) -> Self {
        Self(parsecs, .parsecs)
    }
    
    public init<T: BinaryFloatingPoint>(parsecs: T) {
        self.init(parsecs, .parsecs)
    }
    
    public init<T: BinaryInteger>(parsecs: T) {
        self.init(parsecs, .parsecs)
    }
    
    public var parsecs: Double {
        get { value(in: .parsecs) }
    }
}

/// Measures an area.
public struct Area: Measurement {
    public func value(in unit: Unit) -> Double {
        squareMeters / unit.conversionFactor
    }
    
    public enum Unit: DimensionProtocol {
        public static var base: Self { .squareMeters }
        
        case square(Length.Unit)
        case acres
        case ares
        case hectares
        
        public static var squareMegameters: Self { .square(.megameters) }
        public static var squareKilometers: Self { .square(.kilometers) }
        public static var squareMeters: Self { .square(.meters) }
        public static var squareCentimeters: Self { .square(.centimeters) }
        public static var squareMillimeters: Self { .square(.millimeters) }
        public static var squareMicrometers: Self { .square(.micrometers) }
        public static var squareNanometers: Self { .square(.nanometers) }
        public static var squareInches: Self { .square(.inches) }
        public static var squareFeet: Self { .square(.feet) }
        public static var squareYards: Self { .square(.yards) }
        public static var squareMiles: Self { .square(.miles) }
        
        public var conversionFactor: Double {
            switch self {
            case .acres:
                return 4046.86
            case .ares:
                return 100
            case .hectares:
                return 10000
            case .square(let unit):
                return unit.conversionFactor * unit.conversionFactor
            }
        }
    }
    
    @_implements(Measurement, valueInBaseUnit)
    public var squareMeters: Double
    
    public init(squareMeters: Double) {
        self.squareMeters = squareMeters
    }
    
    public init(valueInBaseUnit: Double) {
        self.init(squareMeters: valueInBaseUnit)
    }
}

extension Area {
    
    public static func squareMegameters<T: BinaryFloatingPoint>(_ squareMegameters: T) -> Self {
        Self(squareMegameters, .squareMegameters)
    }

    public static func squareMegameters<T: BinaryInteger>(_ squareMegameters: T) -> Self {
        Self(squareMegameters, .squareMegameters)
    }

    public init<T: BinaryFloatingPoint>(squareMegameters: T) {
        self.init(squareMegameters, .squareMegameters)
    }

    public init<T: BinaryInteger>(squareMegameters: T) {
        self.init(squareMegameters, .squareMegameters)
    }

    public var squareMegameters: Double {
        get { value(in: .squareMegameters) }
    }

    public static func squareKilometers<T: BinaryFloatingPoint>(_ squareKilometers: T) -> Self {
        Self(squareKilometers, .squareKilometers)
    }

    public static func squareKilometers<T: BinaryInteger>(_ squareKilometers: T) -> Self {
        Self(squareKilometers, .squareKilometers)
    }

    public init<T: BinaryFloatingPoint>(squareKilometers: T) {
        self.init(squareKilometers, .squareKilometers)
    }

    public init<T: BinaryInteger>(squareKilometers: T) {
        self.init(squareKilometers, .squareKilometers)
    }

    public var squareKilometers: Double {
        get { value(in: .squareKilometers) }
    }

    public static func squareMeters<T: BinaryFloatingPoint>(_ squareMeters: T) -> Self {
        Self(squareMeters, .squareMeters)
    }

    public static func squareMeters<T: BinaryInteger>(_ squareMeters: T) -> Self {
        Self(squareMeters, .squareMeters)
    }

    public init<T: BinaryFloatingPoint>(squareMeters: T) {
        self.init(squareMeters, .squareMeters)
    }

    public init<T: BinaryInteger>(squareMeters: T) {
        self.init(squareMeters, .squareMeters)
    }

    public static func squareCentimeters<T: BinaryFloatingPoint>(_ squareCentimeters: T) -> Self {
        Self(squareCentimeters, .squareCentimeters)
    }

    public static func squareCentimeters<T: BinaryInteger>(_ squareCentimeters: T) -> Self {
        Self(squareCentimeters, .squareCentimeters)
    }

    public init<T: BinaryFloatingPoint>(squareCentimeters: T) {
        self.init(squareCentimeters, .squareCentimeters)
    }

    public init<T: BinaryInteger>(squareCentimeters: T) {
        self.init(squareCentimeters, .squareCentimeters)
    }

    public var squareCentimeters: Double {
        get { value(in: .squareCentimeters) }
    }

    public static func squareMillimeters<T: BinaryFloatingPoint>(_ squareMillimeters: T) -> Self {
        Self(squareMillimeters, .squareMillimeters)
    }

    public static func squareMillimeters<T: BinaryInteger>(_ squareMillimeters: T) -> Self {
        Self(squareMillimeters, .squareMillimeters)
    }

    public init<T: BinaryFloatingPoint>(squareMillimeters: T) {
        self.init(squareMillimeters, .squareMillimeters)
    }

    public init<T: BinaryInteger>(squareMillimeters: T) {
        self.init(squareMillimeters, .squareMillimeters)
    }

    public var squareMillimeters: Double {
        get { value(in: .squareMillimeters) }
    }

    public static func squareMicrometers<T: BinaryFloatingPoint>(_ squareMicrometers: T) -> Self {
        Self(squareMicrometers, .squareMicrometers)
    }

    public static func squareMicrometers<T: BinaryInteger>(_ squareMicrometers: T) -> Self {
        Self(squareMicrometers, .squareMicrometers)
    }

    public init<T: BinaryFloatingPoint>(squareMicrometers: T) {
        self.init(squareMicrometers, .squareMicrometers)
    }

    public init<T: BinaryInteger>(squareMicrometers: T) {
        self.init(squareMicrometers, .squareMicrometers)
    }

    public var squareMicrometers: Double {
        get { value(in: .squareMicrometers) }
    }

    public static func squareNanometers<T: BinaryFloatingPoint>(_ squareNanometers: T) -> Self {
        Self(squareNanometers, .squareNanometers)
    }

    public static func squareNanometers<T: BinaryInteger>(_ squareNanometers: T) -> Self {
        Self(squareNanometers, .squareNanometers)
    }

    public init<T: BinaryFloatingPoint>(squareNanometers: T) {
        self.init(squareNanometers, .squareNanometers)
    }

    public init<T: BinaryInteger>(squareNanometers: T) {
        self.init(squareNanometers, .squareNanometers)
    }

    public var squareNanometers: Double {
        get { value(in: .squareNanometers) }
    }

    public static func squareInches<T: BinaryFloatingPoint>(_ squareInches: T) -> Self {
        Self(squareInches, .squareInches)
    }

    public static func squareInches<T: BinaryInteger>(_ squareInches: T) -> Self {
        Self(squareInches, .squareInches)
    }

    public init<T: BinaryFloatingPoint>(squareInches: T) {
        self.init(squareInches, .squareInches)
    }

    public init<T: BinaryInteger>(squareInches: T) {
        self.init(squareInches, .squareInches)
    }

    public var squareInches: Double {
        get { value(in: .squareInches) }
    }

    public static func squareFeet<T: BinaryFloatingPoint>(_ squareFeet: T) -> Self {
        Self(squareFeet, .squareFeet)
    }

    public static func squareFeet<T: BinaryInteger>(_ squareFeet: T) -> Self {
        Self(squareFeet, .squareFeet)
    }

    public init<T: BinaryFloatingPoint>(squareFeet: T) {
        self.init(squareFeet, .squareFeet)
    }

    public init<T: BinaryInteger>(squareFeet: T) {
        self.init(squareFeet, .squareFeet)
    }

    public var squareFeet: Double {
        get { value(in: .squareFeet) }
    }

    public static func squareYards<T: BinaryFloatingPoint>(_ squareYards: T) -> Self {
        Self(squareYards, .squareYards)
    }

    public static func squareYards<T: BinaryInteger>(_ squareYards: T) -> Self {
        Self(squareYards, .squareYards)
    }

    public init<T: BinaryFloatingPoint>(squareYards: T) {
        self.init(squareYards, .squareYards)
    }

    public init<T: BinaryInteger>(squareYards: T) {
        self.init(squareYards, .squareYards)
    }

    public var squareYards: Double {
        get { value(in: .squareYards) }
    }

    public static func squareMiles<T: BinaryFloatingPoint>(_ squareMiles: T) -> Self {
        Self(squareMiles, .squareMiles)
    }

    public static func squareMiles<T: BinaryInteger>(_ squareMiles: T) -> Self {
        Self(squareMiles, .squareMiles)
    }

    public init<T: BinaryFloatingPoint>(squareMiles: T) {
        self.init(squareMiles, .squareMiles)
    }

    public init<T: BinaryInteger>(squareMiles: T) {
        self.init(squareMiles, .squareMiles)
    }

    public var squareMiles: Double {
        get { value(in: .squareMiles) }
    }

    public static func acres<T: BinaryFloatingPoint>(_ acres: T) -> Self {
        Self(acres, .acres)
    }

    public static func acres<T: BinaryInteger>(_ acres: T) -> Self {
        Self(acres, .acres)
    }

    public init<T: BinaryFloatingPoint>(acres: T) {
        self.init(acres, .acres)
    }

    public init<T: BinaryInteger>(acres: T) {
        self.init(acres, .acres)
    }

    public var acres: Double {
        get { value(in: .acres) }
    }

    public static func ares<T: BinaryFloatingPoint>(_ ares: T) -> Self {
        Self(ares, .ares)
    }

    public static func ares<T: BinaryInteger>(_ ares: T) -> Self {
        Self(ares, .ares)
    }

    public init<T: BinaryFloatingPoint>(ares: T) {
        self.init(ares, .ares)
    }

    public init<T: BinaryInteger>(ares: T) {
        self.init(ares, .ares)
    }

    public var ares: Double {
        get { value(in: .ares) }
    }

    public static func hectares<T: BinaryFloatingPoint>(_ hectares: T) -> Self {
        Self(hectares, .hectares)
    }

    public static func hectares<T: BinaryInteger>(_ hectares: T) -> Self {
        Self(hectares, .hectares)
    }

    public init<T: BinaryFloatingPoint>(hectares: T) {
        self.init(hectares, .hectares)
    }

    public init<T: BinaryInteger>(hectares: T) {
        self.init(hectares, .hectares)
    }

    public var hectares: Double {
        get { value(in: .hectares) }
    }
}

/// Measures an angle.
public struct Angle: Measurement {
    public enum Unit: Double, DimensionProtocol {
        case degrees = 1
        case arcMinutes = 0.016667
        case arcSeconds = 0.00027778888
        case radians = 57.2958
        case gradians = 0.9
        case revolutions = 360
        
        public var conversionFactor: Double { rawValue }
        public static var base: Self { .degrees }
    }
    
    @_implements(Measurement, valueInBaseUnit)
    public var degrees: Double
    
    public init(valueInBaseUnit: Double) {
        self.degrees = valueInBaseUnit
    }
}

extension Angle {
    public static func degrees<T: BinaryFloatingPoint>(_ degrees: T) -> Self {
        Self(degrees, .degrees)
    }

    public static func degrees<T: BinaryInteger>(_ degrees: T) -> Self {
        Self(degrees, .degrees)
    }

    public init<T: BinaryFloatingPoint>(degrees: T) {
        self.init(degrees, .degrees)
    }

    public init<T: BinaryInteger>(degrees: T) {
        self.init(degrees, .degrees)
    }

    public static func arcMinutes<T: BinaryFloatingPoint>(_ arcMinutes: T) -> Self {
        Self(arcMinutes, .arcMinutes)
    }

    public static func arcMinutes<T: BinaryInteger>(_ arcMinutes: T) -> Self {
        Self(arcMinutes, .arcMinutes)
    }

    public init<T: BinaryFloatingPoint>(arcMinutes: T) {
        self.init(arcMinutes, .arcMinutes)
    }

    public init<T: BinaryInteger>(arcMinutes: T) {
        self.init(arcMinutes, .arcMinutes)
    }

    public var arcMinutes: Double {
        get { value(in: .arcMinutes) }
    }

    public static func arcSeconds<T: BinaryFloatingPoint>(_ arcSeconds: T) -> Self {
        Self(arcSeconds, .arcSeconds)
    }

    public static func arcSeconds<T: BinaryInteger>(_ arcSeconds: T) -> Self {
        Self(arcSeconds, .arcSeconds)
    }

    public init<T: BinaryFloatingPoint>(arcSeconds: T) {
        self.init(arcSeconds, .arcSeconds)
    }

    public init<T: BinaryInteger>(arcSeconds: T) {
        self.init(arcSeconds, .arcSeconds)
    }

    public var arcSeconds: Double {
        get { value(in: .arcSeconds) }
    }

    public static func radians<T: BinaryFloatingPoint>(_ radians: T) -> Self {
        Self(radians, .radians)
    }

    public static func radians<T: BinaryInteger>(_ radians: T) -> Self {
        Self(radians, .radians)
    }

    public init<T: BinaryFloatingPoint>(radians: T) {
        self.init(radians, .radians)
    }

    public init<T: BinaryInteger>(radians: T) {
        self.init(radians, .radians)
    }

    public var radians: Double {
        get { value(in: .radians) }
    }

    public static func gradians<T: BinaryFloatingPoint>(_ gradians: T) -> Self {
        Self(gradians, .gradians)
    }

    public static func gradians<T: BinaryInteger>(_ gradians: T) -> Self {
        Self(gradians, .gradians)
    }

    public init<T: BinaryFloatingPoint>(gradians: T) {
        self.init(gradians, .gradians)
    }

    public init<T: BinaryInteger>(gradians: T) {
        self.init(gradians, .gradians)
    }

    public var gradians: Double {
        get { value(in: .gradians) }
    }

    public static func revolutions<T: BinaryFloatingPoint>(_ revolutions: T) -> Self {
        Self(revolutions, .revolutions)
    }

    public static func revolutions<T: BinaryInteger>(_ revolutions: T) -> Self {
        Self(revolutions, .revolutions)
    }

    public init<T: BinaryFloatingPoint>(revolutions: T) {
        self.init(revolutions, .revolutions)
    }

    public init<T: BinaryInteger>(revolutions: T) {
        self.init(revolutions, .revolutions)
    }

    public var revolutions: Double {
        get { value(in: .revolutions) }
    }
}

/// Measures a difference in potential energy.
public struct ElectricPotentialDifference: Measurement {
    public init(volts: Double) {
        self.volts = volts
    }
    
    public init(valueInBaseUnit: Double) {
        self.valueInBaseUnit = valueInBaseUnit
    }
    
    public enum Unit: Double, DimensionProtocol {
        case megavolts = 1000000.0
        case kilovolts = 1000.0
        case volts = 1.0
        case millivolts = 0.001
        case microvolts = 0.000001
        
        public var conversionFactor: Double { rawValue }
        public static var base: Self { .volts }
    }
    
    @_implements(Measurement, valueInBaseUnit)
    public var volts: Double
}

extension ElectricPotentialDifference {
    public static func megavolts<T: BinaryFloatingPoint>(_ megavolts: T) -> Self {
        Self(megavolts, .megavolts)
    }

    public static func megavolts<T: BinaryInteger>(_ megavolts: T) -> Self {
        Self(megavolts, .megavolts)
    }

    public init<T: BinaryFloatingPoint>(megavolts: T) {
        self.init(megavolts, .megavolts)
    }

    public init<T: BinaryInteger>(megavolts: T) {
        self.init(megavolts, .megavolts)
    }

    public var megavolts: Double {
        get { value(in: .megavolts) }
    }

    public static func kilovolts<T: BinaryFloatingPoint>(_ kilovolts: T) -> Self {
        Self(kilovolts, .kilovolts)
    }

    public static func kilovolts<T: BinaryInteger>(_ kilovolts: T) -> Self {
        Self(kilovolts, .kilovolts)
    }

    public init<T: BinaryFloatingPoint>(kilovolts: T) {
        self.init(kilovolts, .kilovolts)
    }

    public init<T: BinaryInteger>(kilovolts: T) {
        self.init(kilovolts, .kilovolts)
    }

    public var kilovolts: Double {
        get { value(in: .kilovolts) }
    }

    public static func volts<T: BinaryFloatingPoint>(_ volts: T) -> Self {
        Self(volts, .volts)
    }

    public static func volts<T: BinaryInteger>(_ volts: T) -> Self {
        Self(volts, .volts)
    }

    public init<T: BinaryFloatingPoint>(volts: T) {
        self.init(volts, .volts)
    }

    public init<T: BinaryInteger>(volts: T) {
        self.init(volts, .volts)
    }
    
    public static func millivolts<T: BinaryFloatingPoint>(_ millivolts: T) -> Self {
        Self(millivolts, .millivolts)
    }

    public static func millivolts<T: BinaryInteger>(_ millivolts: T) -> Self {
        Self(millivolts, .millivolts)
    }

    public init<T: BinaryFloatingPoint>(millivolts: T) {
        self.init(millivolts, .millivolts)
    }

    public init<T: BinaryInteger>(millivolts: T) {
        self.init(millivolts, .millivolts)
    }

    public var millivolts: Double {
        get { value(in: .millivolts) }
    }

    public static func microvolts<T: BinaryFloatingPoint>(_ microvolts: T) -> Self {
        Self(microvolts, .microvolts)
    }

    public static func microvolts<T: BinaryInteger>(_ microvolts: T) -> Self {
        Self(microvolts, .microvolts)
    }

    public init<T: BinaryFloatingPoint>(microvolts: T) {
        self.init(microvolts, .microvolts)
    }

    public init<T: BinaryInteger>(microvolts: T) {
        self.init(microvolts, .microvolts)
    }

    public var microvolts: Double {
        get { value(in: .microvolts) }
    }

}

public struct Duration: Measurement {
    public enum Unit: Double, DimensionProtocol {
        public static var base: Duration.Unit { .seconds }
        
        case picoseconds = 1e-12
        case nanoseconds = 1e-9
        case microseconds = 1e-6
        case milliseconds = 1e-3
        case seconds = 1e0
        case minutes = 60
        case hours = 3600
        
        public var conversionFactor: Double { self.rawValue }
    }
    
    @_implements(Measurement, valueInBaseUnit)
    public var seconds: Double
    
    public init(valueInBaseUnit: Double) {
        self.seconds = valueInBaseUnit
    }
}

extension Duration {
    public static func seconds<T: BinaryFloatingPoint>(_ seconds: T) -> Self {
        Self(seconds, .seconds)
    }

    public static func seconds<T: BinaryInteger>(_ seconds: T) -> Self {
        Self(seconds, .seconds)
    }

    public init<T: BinaryFloatingPoint>(seconds: T) {
        self.init(seconds, .seconds)
    }

    public init<T: BinaryInteger>(seconds: T) {
        self.init(seconds, .seconds)
    }
    
    public static func milliseconds<T: BinaryFloatingPoint>(_ milliseconds: T) -> Self {
        Self(milliseconds, .milliseconds)
    }

    public static func milliseconds<T: BinaryInteger>(_ milliseconds: T) -> Self {
        Self(milliseconds, .milliseconds)
    }

    public init<T: BinaryFloatingPoint>(milliseconds: T) {
        self.init(milliseconds, .milliseconds)
    }

    public init<T: BinaryInteger>(milliseconds: T) {
        self.init(milliseconds, .milliseconds)
    }

    public var milliseconds: Double {
        get { value(in: .milliseconds) }
    }

    public static func microseconds<T: BinaryFloatingPoint>(_ microseconds: T) -> Self {
        Self(microseconds, .microseconds)
    }

    public static func microseconds<T: BinaryInteger>(_ microseconds: T) -> Self {
        Self(microseconds, .microseconds)
    }

    public init<T: BinaryFloatingPoint>(microseconds: T) {
        self.init(microseconds, .microseconds)
    }

    public init<T: BinaryInteger>(microseconds: T) {
        self.init(microseconds, .microseconds)
    }

    public var microseconds: Double {
        get { value(in: .microseconds) }
    }

    public static func nanoseconds<T: BinaryFloatingPoint>(_ nanoseconds: T) -> Self {
        Self(nanoseconds, .nanoseconds)
    }

    public static func nanoseconds<T: BinaryInteger>(_ nanoseconds: T) -> Self {
        Self(nanoseconds, .nanoseconds)
    }

    public init<T: BinaryFloatingPoint>(nanoseconds: T) {
        self.init(nanoseconds, .nanoseconds)
    }

    public init<T: BinaryInteger>(nanoseconds: T) {
        self.init(nanoseconds, .nanoseconds)
    }

    public var nanoseconds: Double {
        get { value(in: .nanoseconds) }
    }

    public static func picoseconds<T: BinaryFloatingPoint>(_ picoseconds: T) -> Self {
        Self(picoseconds, .picoseconds)
    }

    public static func picoseconds<T: BinaryInteger>(_ picoseconds: T) -> Self {
        Self(picoseconds, .picoseconds)
    }

    public init<T: BinaryFloatingPoint>(picoseconds: T) {
        self.init(picoseconds, .picoseconds)
    }

    public init<T: BinaryInteger>(picoseconds: T) {
        self.init(picoseconds, .picoseconds)
    }

    public var picoseconds: Double {
        get { value(in: .picoseconds) }
    }

    public static func minutes<T: BinaryFloatingPoint>(_ minutes: T) -> Self {
        Self(minutes, .minutes)
    }

    public static func minutes<T: BinaryInteger>(_ minutes: T) -> Self {
        Self(minutes, .minutes)
    }

    public init<T: BinaryFloatingPoint>(minutes: T) {
        self.init(minutes, .minutes)
    }

    public init<T: BinaryInteger>(minutes: T) {
        self.init(minutes, .minutes)
    }

    public var minutes: Double {
        get { value(in: .minutes) }
    }

    public static func hours<T: BinaryFloatingPoint>(_ hours: T) -> Self {
        Self(hours, .hours)
    }

    public static func hours<T: BinaryInteger>(_ hours: T) -> Self {
        Self(hours, .hours)
    }

    public init<T: BinaryFloatingPoint>(hours: T) {
        self.init(hours, .hours)
    }

    public init<T: BinaryInteger>(hours: T) {
        self.init(hours, .hours)
    }

    public var hours: Double {
        get { value(in: .hours) }
    }
}

