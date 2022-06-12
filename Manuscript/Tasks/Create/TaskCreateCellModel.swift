//
//  TaskCreateCellModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import Foundation

struct TaskCreateCellModel: Hashable {
    let id: String
    let section: TaskCreateSectionType
    let generalInformationCellModel: GeneralInfoCellModel?
    let boardSelectorCellModel: BoardSelectorCellModel?

    init(id: String, generalInformationCellModel: GeneralInfoCellModel) {
        self.id = id
        self.section = .generalInformationSection
        self.generalInformationCellModel = generalInformationCellModel
        self.boardSelectorCellModel = nil
    }
    
    init(id: String, boardSelectorCellModel: BoardSelectorCellModel) {
        self.id = id
        self.section = .boardSelector
        self.generalInformationCellModel = nil
        self.boardSelectorCellModel = boardSelectorCellModel
    }
}
