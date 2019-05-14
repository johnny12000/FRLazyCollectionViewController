//
//  Placeholder.swift
//  FRLazyCollectionViewController
//
//  Created by Nikola Ristic on 5/14/19.
//

import Foundation

/// Placeholder enumeration for lazy-loading values.
enum Placeholder<T>: Equatable {

    /// Empty container for value
    case empty
    /// Lazy-loaded value
    case value(T)

    static func == (lhs: Placeholder, rhs: Placeholder) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }

    /// Retrieves the value of the placeholer, otherwise nil
    func value() -> T? {
        switch self {
        case .value(let val):
            return val
        default:
            return nil
        }
    }
}
