//
//  WorkspaceDetailCellModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/10/22.
//

import Foundation

struct WorkspaceDetailCellModel: Hashable {
    let id: String
    let section: WorksapceDetailSection
    let generalInformationCellModel: WorksapceGeneralInfoCellModel?
    
    init(id: String, generalInformationCellModel: WorksapceGeneralInfoCellModel) {
        self.id = id
        self.section = .generalInformationSection
        self.generalInformationCellModel = generalInformationCellModel
    }
}
