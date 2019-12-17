//
//  Error.swift
//  iMobility Weather
//
//  Created by worker on 17/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

struct Error: Swift.Error {
    
    var message: String {
        self._message ?? self.error?.localizedDescription ?? self.underlyingError?.localizedDescription ?? "Unknown message"
    }
    
    private let _message: String?
    let error: Swift.Error?
    let underlyingError: Swift.Error?
    
    let file: StaticString
    let function: StaticString
    let line: UInt
    
    private init(message: String? = nil,
                 error: Swift.Error? = nil,
                 underlyingError: Swift.Error? = nil,
                 file: StaticString = #file,
                 function: StaticString = #function,
                 line: UInt = #line) {
        self._message = message
        self.error = error
        self.underlyingError = underlyingError
        
        self.file = file
        self.function = function
        self.line = line
    }
    
    init(message: String,
         underlyingError: Swift.Error? = nil,
         file: StaticString = #file,
         function: StaticString = #function,
         line: UInt = #line) {
        self.init(message: message,
                  error: nil,
                  underlyingError: underlyingError,
                  file: file,
                  function: function,
                  line: line
        )
    }
    
    init(with error: Swift.Error,
         underlyingError: Swift.Error? = nil,
         file: StaticString = #file,
         function: StaticString = #function,
         line: UInt = #line) {
        self.init(error: error,
                  underlyingError: underlyingError,
                  file: file,
                  function: function,
                  line: line
        )
    }
    
}

extension Error: LocalizedError {
    
    var errorDescription: String? {
        self.message
    }
    
}
