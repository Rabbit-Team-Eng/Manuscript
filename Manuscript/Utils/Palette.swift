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
        static let CREATE_BOARD_BACKGROUND = "create_board_background"
        static let NOT_SYNCED_MAGENTA = "not_synced_magenta"
        static let RED = "red"

    }
    static let lightBlack = UIColor(named: Constants.BACKGROUND_BLACK)!
    static let gray = UIColor(named: Constants.GRAY)!
    static let blue = UIColor(named: Constants.ACCENT_BLUE)!
    static let lightGray = UIColor(named: Constants.LIGHT_GRAY)!
    static let white = UIColor(named: Constants.WHITE)!
    static let mediumDarkGray = UIColor(named: Constants.CREATE_BOARD_BACKGROUND)!
    static let magenta = UIColor(named: Constants.NOT_SYNCED_MAGENTA)!
    static let red = UIColor(named: Constants.RED)!
}
