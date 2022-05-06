//
//  TabBarFlow.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

enum TabBarFlow: Flowable {

    case boards
    case create
    case tasks
    case profile

    func getNavigationEntryDeepLink() -> String {
        switch self {
        case .boards:
            return "thesis://main/boards"
        case .create:
            return "thesis://main/create"
        case .tasks:
            return "thesis://main/tasks"
        case .profile:
            return "thesis://main/profile"
        }

    }
}
