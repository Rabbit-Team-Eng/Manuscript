//
//  ManuscriptEnvironment.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

enum ManuscriptEnvironment: String {
    case local = "http://localhost:5000/"
    case stage = "https://stage.tasky.space/"
    case production = "https://api.tasky.space/"
}
