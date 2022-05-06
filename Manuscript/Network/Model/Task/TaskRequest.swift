//
//  TaskRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public struct TaskRequest: Codable {

    public var boardId: Int
    public var title: String
    public var detail: String
    public var doeDate: String?
    public var assigneeId: String?

    public init(boardId: Int, title: String, detail: String, doeDate: String? = nil, assigneeId: String? = nil) {
        self.boardId = boardId
        self.title = title
        self.detail = detail
        self.doeDate = doeDate
        self.assigneeId = assigneeId
    }
}
