//
//  BoardAPI.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation
import Combine

public protocol BoardAPI {
    
    func createNewBoard(requestBody: BoardRequest) -> AnyPublisher<BoardResponse, Error>
    
    func getAllBoards() -> AnyPublisher<AllBoardsResponse, Error>
    
    func getAllBoardsWithPredicate(accessToken: String, workspaceId: String, pageNumber: Int, pageSize: Int) -> AnyPublisher<AllBoardsResponse, Error>
    
    func updateBoardById(requestBody: BoardRequest, boardId: Int64) -> AnyPublisher<BoardResponse, Error>
    
    func deleteBoardById(boardId: Int64) -> AnyPublisher<Int, Error>
    
}
  
