//
//  File.swift
//  
//
//  Created by Eric Bodnick on 10/15/22.
//

import Foundation

extension Exception.Name: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

/// An unrecoverable error.
public struct Exception: RawRepresentable {
    public typealias Name = NSExceptionName
    
    public var rawValue: NSException
    
    public init(rawValue: NSException) { self.rawValue = rawValue }
    
    public static func raise(_ name: Name, reason: String) {
        withVaList([]) {
            NSException.raise(name, format: "reason", arguments: $0)
        }
    }
    
    public init(name: Name, reason: String? = nil) {
        self.rawValue = NSException(name: name, reason: reason)
    }
    
    public var callStackSymbols: [String] { rawValue.callStackSymbols }
    public var callStackReturnAdresses: [UInt] { rawValue.callStackReturnAddresses.map(\.uintValue) }
}

/// An option to recover an error.
public struct Recovery {
    /// The name of the recovery option.
    public var name: String
    
    /// Attempt to recover the error.
    public var recover: () -> Void
}

/// An errror that may be recoverable by showing recovery options to the user.
public protocol RecoverableError: Error {
    var recoveryOptions: [Recovery] { get }
}

/// An error that is localized.
public protocol LocalizedError: Error, CustomStringConvertible {
    var failureReason: String { get }
    var recoverySuggestion: String { get }
}

/// An error that's localized and may be recoverable.
public typealias LocalizedRecoverableError = LocalizedError & RecoverableError
