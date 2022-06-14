//
//  File.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import Foundation

protocol TaskCellProtocol: NSObject {
    func taskDidSelected(task: TaskBusinessModel)
}
