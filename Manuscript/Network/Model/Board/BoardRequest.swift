//
//  BoardRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public struct BoardRequest: Codable {
    
    public var workspaceId: Int
    public var assetUrl: String
    public var title: String

    public init(workspaceId: Int, assetUrl: String, title: String) {
        self.workspaceId = workspaceId
        self.assetUrl = assetUrl
        self.title = title
    }
}

