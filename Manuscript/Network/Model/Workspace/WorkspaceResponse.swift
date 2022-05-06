//
//  WorkspaceResponse.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public struct WorkspaceResponse: Codable, Syncable {
    
    public var id: Int
    public var title: String
    public var description: String? = nil
    public var boards: [BoardResponse]? = nil
    public var members: [MemberResponse]? = nil
    public var shareEnabled: Bool
    public var lastModifiedDate: String = ""

    public init(id: Int, title: String, description: String?, boards: [BoardResponse]? = nil, members: [MemberResponse]? = nil, shareEnabled: Bool, lastModifiedDate: String) {
        self.id = id
        self.title = title
        self.description = description
        self.boards = boards
        self.members = members
        self.shareEnabled = shareEnabled
        self.lastModifiedDate = lastModifiedDate
    }
}
