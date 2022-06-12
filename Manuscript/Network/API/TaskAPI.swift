//
//  TaskAPI.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation
import Combine

public protocol TaskAPI {
    func createTask(requestBody: TaskRequest) -> AnyPublisher<TaskResponse, Error>
    func getAllTasks() -> AnyPublisher<AllTaskResponse, Error>
    func updateTaskById(requestBody: TaskRequest, taskId: String) -> AnyPublisher<TaskResponse, Error>
    func deleteTaskById(taskId: String) -> AnyPublisher<TaskResponse, Error>
}
