//
//  WorksapceDetailSection.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/10/22.
//

import Foundation

enum WorksapceDetailSection: Hashable {
    case generalInformationSection
    case sharing
    case members

    var sectionHeaderTitle: String? {
        switch self {
        case .generalInformationSection:
            return "General Information"
        case .sharing:
            return "Sharing"
        case .members:
            return "Members"
        default:
            return nil
        }
    }
    
    var sectionFooterTitle: String? {
        switch self {
        case .members:
            return "See More"
        default:
            return nil
        }
    }
}
