//
//  File.swift
//  
//
//  Created by Eric Bodnick on 11/18/22.
//

import Foundation

 public protocol Formattable<FormatStyle> {
    /// Creating a FormatStyle instance can be expensive, so don't create new ones in a tight loop. Try to reuse FormatStyle instances.
     ///
     /// ```swift
     /// // Bad:
     /// for i in 1...100 {
     ///    print(i.formatted(.spellOut))
     /// }
     ///
     /// // Good:
     ///
     /// let formatter = Formatter<Int>(.spellOut)
     ///
     /// for i in in 1...100 {
     ///    print(i.formatted(with: formatter))
     /// }
    associatedtype FormatStyle: FormatStyleProtocol
    func formatted(_ style: FormatStyle) -> String
 }
 
 public protocol ReverseFormattable: Formattable {
     init?(_ string: String, style: FormatStyle)
 }
 
 public protocol FormatStyleProtocol {
     static var standard: Self { get }
     
     associatedtype Finalized
     func finalize() -> Finalized
 }
 
 public struct Formatter<Formatted: Formattable> {
     public var style: Formatted.FormatStyle
     public func format(_ value: Formatted) -> String {
         value.formatted(style)
     }
    
     public func callAsFunction(_ value: Formatted) -> String {
         value.formatted(style)
     }
     
     public init(_ style: Formatted.FormatStyle) {
         self.style = style
     }
 }
 
 extension Formatter where Formatted: ReverseFormattable {
     public func value(from string: String) -> Formatted? {
         Formatted(string, style: style)
     }
 }
 
 extension Formattable {
     public func formatted() -> String {
         self.formatted(.standard)
     }
     
     public func formatted(with formatter: Formatter<Self>) -> String {
         formatter(self)
     }
 }
 
 extension ReverseFormattable {
     public init?(_ other: String) {
         self.init(other, style: .standard)
     }
 }

infix operator ?=

public func ?= <T> (lhs: inout T, rhs: T?) {
    if let rhs {
        lhs = rhs
    }
}
/*

public struct NumberFormatStyle: FormatStyleProtocol {
    public static var standard: NumberFormatStyle {
        NumberFormatStyle(style: NumberFormatter.Style.none)
    }
    
    public init(
        style: NumberFormatter.Style? = nil,
        generatesDecimalNumbers: Bool? = nil,
        localizesFormat: Bool? = nil,
        locale: Locale? = nil,
        roundingIncrement: Double? = nil,
        roundingMode: NumberFormatter.RoundingMode? = nil,
        minimumIntegerDigits: Int? = nil,
        maximumIntegerDigits: Int? = nil,
        minimumFractionDigits: Int? = nil,
        maximumFractionDigits: Int? = nil,
        usesSignificantDigits: Bool? = nil,
        minimumSignificantDigits: Int? = nil,
        maximumSignificantDigits: Int? = nil,
        percentSymbol: String? = nil,
        perMillSymbol: String? = nil,
        minusSign: String? = nil,
        plusSign: String? = nil,
        exponentSymbol: String? = nil,
        zeroSymbol: String? = nil,
        nilSymbol: String? = nil,
        negativeInfinitySymbol: String? = nil,
        infinitySymbol: String? = nil,
        currencySymbol: String? = nil,
        currencyCode: String? = nil,
        internationalCurrencySymbol: String? = nil,
        currencyGroupingSeparator: String? = nil,
        positivePrefix: String? = nil,
        positiveSuffix: String? = nil,
        negativePrefix: String? = nil,
        negativeSuffix: String? = nil,
        groupingSeparator: String? = nil,
        usesGroupingSeparator: Bool? = nil,
        thousandSeparator: String? = nil,
        hasThousandSeparators: Bool? = nil,
        decimalSeparator: String? = nil,
        alwaysShowsDecimalSeparator: Bool? = nil,
        currencyDecimalSeparator: String? = nil,
        groupingSize: Int? = nil,
        secondaryGroupingSize: Int? = nil,
        paddingCharacter: String? = nil,
        paddingPosition: NumberFormatter.PadPosition? = nil,
        allowsFloats: Bool? = nil,
        minimumInput: Double? = nil,
        maximumInput: Double? = nil,
        isLenient: Bool? = nil
    ) {
        self.style = style
        self.generatesDecimalNumbers = generatesDecimalNumbers
        self.localizesFormat = localizesFormat
        self.locale = locale
        self.roundingIncrement = roundingIncrement
        self.roundingMode = roundingMode
        self.minimumIntegerDigits = minimumIntegerDigits
        self.maximumIntegerDigits = maximumIntegerDigits
        self.minimumFractionDigits = minimumFractionDigits
        self.maximumFractionDigits = maximumFractionDigits
        self.usesSignificantDigits = usesSignificantDigits
        self.minimumSignificantDigits = minimumSignificantDigits
        self.maximumSignificantDigits = maximumSignificantDigits
        self.percentSymbol = percentSymbol
        self.perMillSymbol = perMillSymbol
        self.minusSign = minusSign
        self.plusSign = plusSign
        self.exponentSymbol = exponentSymbol
        self.zeroSymbol = zeroSymbol
        self.nilSymbol = nilSymbol
        self.negativeInfinitySymbol = negativeInfinitySymbol
        self.infinitySymbol = infinitySymbol
        self.currencySymbol = currencySymbol
        self.currencyCode = currencyCode
        self.internationalCurrencySymbol = internationalCurrencySymbol
        self.currencyGroupingSeparator = currencyGroupingSeparator
        self.positivePrefix = positivePrefix
        self.positiveSuffix = positiveSuffix
        self.negativePrefix = negativePrefix
        self.negativeSuffix = negativeSuffix
        self.groupingSeparator = groupingSeparator
        self.usesGroupingSeparator = usesGroupingSeparator
        self.thousandSeparator = thousandSeparator
        self.hasThousandSeparators = hasThousandSeparators
        self.decimalSeparator = decimalSeparator
        self.alwaysShowsDecimalSeparator = alwaysShowsDecimalSeparator
        self.currencyDecimalSeparator = currencyDecimalSeparator
        self.groupingSize = groupingSize
        self.secondaryGroupingSize = secondaryGroupingSize
        self.paddingCharacter = paddingCharacter
        self.paddingPosition = paddingPosition
        self.allowsFloats = allowsFloats
        self.minimumInput = minimumInput
        self.maximumInput = maximumInput
        self.isLenient = isLenient
    }
    
    public var style: NumberFormatter.Style?
    public var generatesDecimalNumbers: Bool?
    public var localizesFormat: Bool?
    public var locale: Locale?
    
    public var roundingIncrement: Double?
    public var roundingMode: NumberFormatter.RoundingMode?
    
    public var minimumIntegerDigits: Int?
    public var maximumIntegerDigits: Int?
    public var minimumFractionDigits: Int?
    public var maximumFractionDigits: Int?
    
    public var usesSignificantDigits: Bool?
    public var minimumSignificantDigits: Int?
    public var maximumSignificantDigits: Int?
    
    public var percentSymbol: String?
    public var perMillSymbol: String?
    public var minusSign: String?
    public var plusSign: String?
    public var exponentSymbol: String?
    public var zeroSymbol: String?
    public var nilSymbol: String?
    public var negativeInfinitySymbol: String?
    public var infinitySymbol: String?
    
    public var currencySymbol: String?
    public var currencyCode: String?
    public var internationalCurrencySymbol: String?
    public var currencyGroupingSeparator: String?
    
    public var positivePrefix: String?
    public var positiveSuffix: String?
    public var negativePrefix: String?
    public var negativeSuffix: String?
    
    public var groupingSeparator: String?
    public var usesGroupingSeparator: Bool?
    public var thousandSeparator: String?
    public var hasThousandSeparators: Bool?
    public var decimalSeparator: String?
    public var alwaysShowsDecimalSeparator: Bool?
    public var currencyDecimalSeparator: String?
    public var groupingSize: Int?
    public var secondaryGroupingSize: Int?
    
    public var paddingCharacter: String?
    public var paddingPosition: NumberFormatter.PadPosition?
    
    public var allowsFloats: Bool?
    public var minimumInput: Double?
    public var maximumInput: Double?
    
    public var isLenient: Bool?
}

extension NumberFormatter {
    convenience init(_ style: NumberFormatStyle) {
        self.init()
        self.numberStyle ?= style.style
        
    }
}

*/
