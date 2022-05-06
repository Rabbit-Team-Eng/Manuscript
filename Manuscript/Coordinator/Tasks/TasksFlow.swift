//
//  TasksFlow.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

enum TasksFlow: Flowable {

    case tasks
    case tasksDetail


    func getNavigationEntryDeepLink() -> String {
        switch self {
        case .tasks:
            return "thesis://main/tasks"
        case .tasksDetail:
            return "thesis://main/tasksDetail?id=mock_id"
        }

    }
}
