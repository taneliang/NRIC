//
//  NRIC.swift
//
//  Created by E-Liang Tan on 6/26/16.
//  Copyright (c) 2016 E-Liang Tan
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

/// An NRIC number.
struct NRIC {
    
    enum Error: ErrorProtocol {
        /// Invalid NRIC length or invalid the number of digits.
        ///
        /// A complete NRIC should have 9 characters, consisting of 2 letters and 7 digits.
        case lengthError
        
        /// One or more invalid characters were provided.
        ///
        /// A valid NRIC should satisfy the regex `^[STFG][0-9]{7}[ABCDEFGHIKJLMNPQRTUWXZ]$`.
        case invalidCharacterError
        /// Invalid prefix.
        ///
        /// There are only 4 valid prefixes: `S`, `T`, `F`, and `G`.
        case prefixError
    }
    
    /// NRIC Prefixes
    ///
    /// The first character of an NRIC can only be either `S`, `T`, `F`, or `G`.
    enum Prefix: Character {
        case s = "S"
        case t = "T"
        case f = "F"
        case g = "G"
    }
    
    let prefix: Prefix
    let digits: [Int] // Count must be 7
    let checkDigit: Character
    
    /// Initialize an NRIC with a prefix, digits, and an optional check digit.
    ///
    /// - parameter prefix: The NRIC prefix.
    /// - parameter digits: An array of 7 NRIC digits. If the count of this array is not 7, `NRIC.Error.lengthError` will be thrown.
    /// - parameter checkDigit: Optional; if nil, the check digit will be calculated using `NRIC.calculatedCheckDigit(prefix:digits:)`
    init(prefix: Prefix, digits: [Int], checkDigit: Character? = nil) throws {
        // Get prefix
        self.prefix = prefix
        
        // Get digits
        if digits.count == 7 {
            self.digits = digits
        } else {
            throw Error.lengthError
        }
        
        // Get or calculate check digit
        if let checkDigit = checkDigit {
            self.checkDigit = checkDigit
        } else {
            self.checkDigit = try NRIC.calculatedCheckDigit(prefix: prefix, digits: digits)
        }
    }
    
    /// Initialize an NRIC from a `String`.
    ///
    /// - parameter NRICString: The `String` representation of an NRIC.
    ///
    ///     An error will be thrown if an invalid NRIC is provided.
    init(NRICString: String) throws {
        // Length
        if NRICString.characters.count != 9 {
            throw Error.lengthError
        }
        
        // Structure
        let regex = try? RegularExpression(pattern: "^[STFG][0-9]{7}[ABCDEFGHIKJLMNPQRTUWXZ]$", options: .allowCommentsAndWhitespace)
        if let regex = regex where regex.numberOfMatches(in: NRICString, options: .reportCompletion, range: NSRange(location: 0,length: 9)) != 1 {
            throw Error.invalidCharacterError
        }
        
        // NRICString is valid
        
        // Get prefix
        let characters = NRICString.characters
        if let prefix = Prefix(rawValue: characters.first!) {
            self.prefix = prefix
        } else {
            throw Error.prefixError
        }
        
        // Get digits
        let digitString = String(characters[characters.index(after: characters.startIndex)..<characters.index(before: characters.endIndex)])
        let digits = digitString.characters.flatMap { Int(String($0)) }
        if digits.count == 7 {
            self.digits = digits
        } else {
            throw Error.lengthError
        }
        
        // Get check digit
        checkDigit = characters.last!
    }
    
    /// Calculate an NRIC check digit
    ///
    /// The check digit is calulated using [an algorithm by Ngiam Shih Tung](http://www.ngiam.net/NRIC/NRIC_numbers.pdf).
    ///
    /// - parameter prefix: The NRIC prefix.
    /// - parameter digits: An array of 7 NRIC digits. If the count of this array is not 7, `NRIC.Error.lengthError` will be thrown.
    /// - returns: The check digit.
    static func calculatedCheckDigit(prefix: Prefix, digits: [Int]) throws -> Character {
        guard digits.count == 7 else {
            throw Error.lengthError
        }
        
        // d0 = 0 if prefix is S or F, otherwise d0 = 4 if prefix is T or G
        let d0: Int
        if prefix == Prefix.s || prefix == Prefix.f { d0 = 0 }
        else /* if prefix == Prefix.t || prefix == Prefix.g */ { d0 = 4 }
        
        // Calculate `d` using the formula `d = [(d1 d2 d3 d4 d5 d6 d7)*(2 7 6 5 4 3 2)] mod 11`
        let digitAndWeights = zip(digits, [2,7,6,5,4,3,2])
        let d = (d0 + digitAndWeights.reduce(0) { $0 + $1.0 * $1.1 }) % 11
        
        // Define lookup tables
        let checkDigitUINLookupTable: [Character] = ["J","Z","I","H","G","F","E","D","C","B","A"]
        let checkDigitFINLookupTable: [Character] = ["X","W","U","T","R","Q","P","N","M","L","K"]
        
        // Perform lookups
        let calculatedCheckDigit: Character
        if prefix == Prefix.s || prefix == Prefix.t { calculatedCheckDigit = checkDigitUINLookupTable[d] }
        else /* if prefix == Prefix.f || prefix == Prefix.g */ { calculatedCheckDigit = checkDigitFINLookupTable[d] }
        
        return calculatedCheckDigit
    }
    
    /// Check `self` is a valid NRIC.
    ///
    /// - returns: Whether `self` is a valid NRIC.
    func isValid() -> Bool {
        if let calculatedCheckDigit = try? NRIC.calculatedCheckDigit(prefix: prefix, digits: digits) {
            return checkDigit == calculatedCheckDigit // Valid if both the provided and calculated check digits match
        }
        return false
    }
}

extension NRIC: CustomStringConvertible {
    var description: String {
        return String(prefix.rawValue) + String(digits.map { Character(String($0)) }) + String(checkDigit)
    }
}
