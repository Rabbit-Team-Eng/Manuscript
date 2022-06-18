//
//  ApplicationInjector.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

class ApplicationInjector {

    private var startupUtils: StartupUtils? = nil
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    func provideStartupUtils() -> StartupUtils {
        if startupUtils != nil {
            return startupUtils!
        } else {
            startupUtils = StartupUtils()
            return startupUtils!
        }
    }

    func provideJsonDecoder() -> JSONDecoder {
        return jsonDecoder
    }

    func provideJsonEncoder() -> JSONEncoder {
        return jsonEncoder
    }

    init() {

    }

    deinit {

    }
}

