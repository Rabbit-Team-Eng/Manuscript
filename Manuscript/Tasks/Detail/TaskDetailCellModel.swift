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
    let priorityCellModel: PrioritySelectorCellModel?

    init(id: String, generalInformationCellModel: TaskGeneralInfoCellModel) {
        self.id = id
        self.section = .generalInformationSection
        self.generalInformationCellModel = generalInformationCellModel
        self.boardSelectorCellModel = nil
        self.priorityCellModel = nil
    }
    
    init(id: String, boardSelectorCellModel: BoardSelectorCellModel) {
        self.id = id
        self.section = .boardSelectorSection
        self.generalInformationCellModel = nil
        self.boardSelectorCellModel = boardSelectorCellModel
        self.priorityCellModel = nil
    }
    
    init(id: String, priorityCellModel: PrioritySelectorCellModel) {
        self.id = id
        self.section = .prioritySection
        self.generalInformationCellModel = nil
        self.boardSelectorCellModel = nil
        self.priorityCellModel = priorityCellModel
    }
}
