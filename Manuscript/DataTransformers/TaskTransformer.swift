//
//  TaskTransformer.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/13/22.
//

import Foundation

struct TaskTransformer {
    
    static func transformTasksToTaskCellModel(tasks: [TaskBusinessModel]) -> [TaskCellModel] {
     
        return tasks.map { task in
            TaskCellModel(id: "\(task.remoteId)",
                          title: task.title,
                          description: task.detail ?? "",
                          priority: task.priority,
                          assignee: task.assigneeUserId,
                          status: task.status,
                          boardTitle: "\(task.ownerBoardId)")
        }
        
    }
}
