//
//  DatabaseEventProtocol.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import Foundation

protocol DatabaseEventProtocol: NSObject {
    func eventDidHappen(action: DatabaseAction)
}
