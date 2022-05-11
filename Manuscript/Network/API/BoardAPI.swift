//
//  BoardAPI.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation
import Combine

public protocol BoardAPI {
    
    func createNewBoard(accessToken: String, requestBody: BoardRequest) -> AnyPublisher<BoardResponse, Error>
    
    func getAllBoards() -> AnyPublisher<AllBoardsResponse, Error>
    
    func getAllBoardsWithPredicate(accessToken: String, workspaceId: String, pageNumber: Int, pageSize: Int) -> AnyPublisher<AllBoardsResponse, Error>
    
    func updateBoardById(accessToken: String, requestBody: BoardRequest, boardId: String) -> AnyPublisher<BoardResponse, Error>
    
    func deleteBoardById(accessToken: String, boardId: String) -> AnyPublisher<BoardResponse, Error>
    
}
  
