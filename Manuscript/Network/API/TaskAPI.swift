//
//  TaskAPI.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation
import Combine

public protocol TaskAPI {
    func createTask(accessToken: String, requestBody: TaskRequest) -> AnyPublisher<TaskResponse, Error>
    func getAllTasks(accessToken: String) -> AnyPublisher<AllTaskResponse, Error>
    func updateTaskById(accessToken: String, requestBody: TaskRequest, taskId: String) -> AnyPublisher<TaskResponse, Error>
    func deleteTaskById(accessToken: String, taskId: String) -> AnyPublisher<TaskResponse, Error>
}
