//
//  TaskCreateCellModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import Foundation

struct TaskDetailCellModel: Hashable {
    let id: String
    let section: TaskDetailSectionType
    let generalInformationCellModel: TaskGeneralInfoCellModel?
    let boardSelectorCellModel: BoardSelectorCellModel?

    init(id: String, generalInformationCellModel: TaskGeneralInfoCellModel) {
        self.id = id
        self.section = .generalInformationSection
        self.generalInformationCellModel = generalInformationCellModel
        self.boardSelectorCellModel = nil
    }
    
    init(id: String, boardSelectorCellModel: BoardSelectorCellModel) {
        self.id = id
        self.section = .boardSelectorSection
        self.generalInformationCellModel = nil
        self.boardSelectorCellModel = boardSelectorCellModel
    }
}
