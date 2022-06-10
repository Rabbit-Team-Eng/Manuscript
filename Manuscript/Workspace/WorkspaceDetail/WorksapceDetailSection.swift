//
//  WorksapceDetailSection.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/10/22.
//

import Foundation

enum WorksapceDetailSection: Hashable {
    case generalInformationSection
    case sharingSection
    case membersSection

    var sectionHeaderTitle: String? {
        switch self {
        case .generalInformationSection:
            return "General Information"
        case .sharingSection:
            return "Sharing"
        case .membersSection:
            return "Members"
        default:
            return nil
        }
    }
    
    var sectionFooterTitle: String? {
        switch self {
        case .membersSection:
            return "See More"
        default:
            return nil
        }
    }
}
