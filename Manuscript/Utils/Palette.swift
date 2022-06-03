//
//  Palette.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

struct Palette {

    private struct Constants {
        static let BACKGROUND_BLACK = "background_black"
        static let GRAY = "gray"
        static let ACCENT_BLUE = "accent_blue"
        static let LIGHT_GRAY = "light_gray"
        static let WHITE = "white"
    }
    static let lightBlack = UIColor(named: Constants.BACKGROUND_BLACK)!
    static let gray = UIColor(named: Constants.GRAY)!
    static let blue = UIColor(named: Constants.ACCENT_BLUE)!
    static let lightGray = UIColor(named: Constants.LIGHT_GRAY)!
    static let white = UIColor(named: Constants.WHITE)!
}
