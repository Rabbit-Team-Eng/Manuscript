//
//  TaskRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public struct TaskRequest: Codable {

    public var boardId: Int64
    public var title: String
    public var detail: String
    public var doeDate: String?
    public var assigneeId: String?
    public var priority: String?
    public var status: String?

}
