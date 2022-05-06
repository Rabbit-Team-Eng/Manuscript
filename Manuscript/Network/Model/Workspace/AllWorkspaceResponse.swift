//
//  AllWorkspaceResponse.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public struct AllWorkspaceResponse: Codable {
    public var items: [WorkspaceResponse]
    public var totalPages: Int
    public var totalItemsCount: Int
    public var pageNumber: Int
    
    public init(items: [WorkspaceResponse],
                totalPages: Int,
                totalItemsCount: Int,
                pageNumber: Int)
    {
        self.items = items
        self.totalPages = totalPages
        self.totalItemsCount = totalItemsCount
        self.pageNumber = pageNumber
    }
    
}
