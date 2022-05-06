//
//  Syncable.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public protocol Syncable {
    var lastModifiedDate: String { get }
}
