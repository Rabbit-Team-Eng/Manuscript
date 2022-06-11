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
    let generalInformationCellModel: GeneralInfoCellModel?
    let manageAccessCellModel: ManageAcessCellModel?

    init(id: String, generalInformationCellModel: GeneralInfoCellModel) {
        self.id = id
        self.section = .generalInformationSection
        self.generalInformationCellModel = generalInformationCellModel
        self.manageAccessCellModel = nil
    }
    
    init(id: String, manageAccessCellModel: ManageAcessCellModel) {
        self.id = id
        self.section = .sharingSection
        self.generalInformationCellModel = nil
        self.manageAccessCellModel = manageAccessCellModel
    }
}
