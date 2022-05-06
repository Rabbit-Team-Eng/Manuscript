//
//  BoardError.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public enum BoardError: Error {
    case unableToCreateBoard(errorMessage: String)
    case badAccessToken
    case unableToGetAllBoard(errorMessage: String)
    case unableToDecodeResponse(errorMessage: String)
}
