//
//  WorkspaceResponse.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public struct WorkspaceResponse: Codable, Syncable {
    
    public var id: Int64
    public var title: String
    public var description: String? = nil
    public var boards: [BoardResponse]? = nil
    public var members: [MemberResponse]? = nil
    public var shareEnabled: Bool
    public var lastModifiedDate: String = ""

}
