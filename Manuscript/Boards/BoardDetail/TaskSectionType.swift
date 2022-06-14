//
//  BoardDetailSectionType.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import Foundation

enum TaskSectionType: Hashable {
    case highPrioritySection
    case mediumPrioritySection
    case lowPrioritySection

    var sectionHeaderTitle: String? {
        switch self {
        case .highPrioritySection:
            return "High Priority"
        case .mediumPrioritySection:
            return "Medium Priority"
        case .lowPrioritySection:
            return "Low Priority"
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
