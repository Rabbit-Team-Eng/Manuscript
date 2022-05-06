//
//  TaskResponse.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public struct TaskResponse: Codable, Syncable {

    public var id: Int
    public var boardId: Int
    public var workspaceId: Int
    public var title: String
    public var detail: String
    public var doeDate: String
    public var status: String? = nil
    public var lastModifiedDate: String

    public init(id: Int, boardId: Int, workspaceId: Int, title: String, detail: String, doeDate: String, status: String?, lastModifiedDate: String) {
        self.id = id
        self.boardId = boardId
        self.workspaceId = workspaceId
        self.title = title
        self.detail = detail
        self.doeDate = doeDate
        self.status = status
        self.lastModifiedDate = lastModifiedDate
    }
}
