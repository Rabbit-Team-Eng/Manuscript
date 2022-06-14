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
    public var workspaceId: Int64
    public var assigneeId: String?
    public var title: String
    public var detail: String
    public var doeDate: String
    public var status: String? = nil
    public var priority: String
    public var lastModifiedDate: String

}
