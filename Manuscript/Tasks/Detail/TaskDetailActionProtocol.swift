//
//  TaskCreateActionProtocol.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import Foundation

protocol TaskDetailActionProtocol: NSObject {
    func actionDidHappen(action: TaskDetailAction)
}
