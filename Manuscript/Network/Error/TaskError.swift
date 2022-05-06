//
//  TaskError.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation
public enum TaskError: Error {
    case unableToCreateTask(errorMessage: String)
    case badAccessToken
    case unableToGetAllTasks(errorMessage: String)
}
