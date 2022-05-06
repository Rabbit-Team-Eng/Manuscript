//
//  ApplicationInjector.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

class ApplicationInjector {

    private let startupUtils: StartupUtils = StartupUtils()
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = JSONDecoder()

    func provideStartupUtils() -> StartupUtils {
        return startupUtils
    }

    func provideJsonDecoder() -> JSONDecoder {
        return jsonDecoder
    }

    func provideJsonEncoder() -> JSONEncoder {
        return jsonEncoder
    }

    init() {
        print("AVERAKEDABRA: ALLOC -> ApplicationComponent")
    }

    deinit {
        print("AVERAKEDABRA: RELEASE -> ApplicationComponent")
    }
}

