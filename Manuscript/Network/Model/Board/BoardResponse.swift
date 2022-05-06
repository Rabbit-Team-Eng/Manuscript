//
//  BoardResponse.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation
public struct BoardResponse: Codable, Syncable {
    
    public var id: Int
    public var workspaceId: Int
    public var assetUrl: String? = nil
    public var title: String
    public var tasks: [TaskResponse]? = nil
    public var lastModifiedDate: String

    public init(id: Int, workspaceId: Int, assetUrl: String?, title: String, tasks: [TaskResponse]? = nil, lastModifiedDate: String) {
        self.id = id
        self.workspaceId = workspaceId
        self.assetUrl = assetUrl
        self.title = title
        self.tasks = tasks
        self.lastModifiedDate = lastModifiedDate
    }
}
