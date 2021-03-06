//
//  TaskBoardSelectorSectionType.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import Foundation

enum TaskDetailSectionType: Hashable {
    case generalInformationSection
    case boardSelectorSection
    case prioritySection

    var sectionHeaderTitle: String? {
        switch self {
        case .generalInformationSection:
            return "General Information"
        case .boardSelectorSection:
            return "Select Board"
        case .prioritySection:
            return "Choose Priority"
        default:
            return nil
        }
    }
    
    var sectionFooterTitle: String? {
        switch self {
        default:
            return nil
        }
    }
}
