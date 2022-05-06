//
//  WorkspaceRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public struct WorkspaceRequest: Codable {
    
    public var title: String
    public var description: String
    public var shareEnabled: Bool?
    
    public init(title: String, description: String, shareEnabled: Bool) {
        self.title = title
        self.description = description
        self.shareEnabled = shareEnabled
    }
}
