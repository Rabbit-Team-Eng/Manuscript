//
//  TaskBoardSelectorSectionType.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import Foundation

enum TaskCreateSectionType: Hashable {
    case generalInformationSection
    case boardSelectorSection
    
    var sectionHeaderTitle: String? {
        switch self {
        case .generalInformationSection:
            return "General Information"
        case .boardSelectorSection:
            return "Select Board"
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
