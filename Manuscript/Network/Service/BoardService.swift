//
//  BoardService.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Combine
import Foundation

public class BoardService: BoardAPI {
    
    private let environment: ManuscriptEnvironment
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private let accessToken: String

    init(accessToken: String, environment: ManuscriptEnvironment, jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.accessToken = accessToken
        self.environment = environment
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    public func createNewBoard(accessToken: String, requestBody: BoardRequest) -> AnyPublisher<BoardResponse, Error> {

        let request = CreateNewBoardRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getRequest(with: requestBody))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                return element.data
            }
            .decode(type: BoardResponse.self, decoder: jsonDecoder)
            .mapError({ error in
                return BoardError.unableToCreateBoard(errorMessage: "Decoding error.")
            })
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .eraseToAnyPublisher()
    }
    
    public func getAllBoards(accessToken: String, workspaceId: String) -> AnyPublisher<AllBoardsResponse, Error> {

        let request = GetAllBoardsRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getRequestForAllWorkspaces(workspaceId: workspaceId))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                return element.data
            }
            .decode(type: AllBoardsResponse.self, decoder: jsonDecoder)
            .mapError({ error in
                return BoardError.unableToCreateBoard(errorMessage: "Decoding error. \(error.localizedDescription)")
            })
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .eraseToAnyPublisher()
    }
    
    public func getAllBoardsWithPredicate(accessToken: String, workspaceId: String, pageNumber: Int, pageSize: Int) -> AnyPublisher<AllBoardsResponse, Error> {
        
        let request = GetAllBoardsRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getPredicateRequest(workspaceId: workspaceId, with: pageNumber, pageSize: pageSize))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                return element.data
            }
            .decode(type: AllBoardsResponse.self, decoder: jsonDecoder)
            .mapError({ error in
                return BoardError.unableToGetAllBoard(errorMessage: "Decoding error.")
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    public func updateBoardById(accessToken: String, requestBody: BoardRequest, boardId: String) -> AnyPublisher<BoardResponse, Error> {
        
        let request = UpdateBoardRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getRequest(body: requestBody, boardId: boardId))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                return element.data
            }
            .decode(type: BoardResponse.self, decoder: jsonDecoder)
            .mapError({ error in
                return BoardError.unableToGetAllBoard(errorMessage: "Decoding error.")
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    public func deleteBoardById(accessToken: String, boardId: String) -> AnyPublisher<BoardResponse, Error> {
        
        let request = DeleteBoardRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getRequest(boardId: boardId))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                
                return element.data
            }
            .decode(type: BoardResponse.self, decoder: jsonDecoder)
            .mapError({ error in
                return BoardError.unableToDecodeResponse(errorMessage: "Decoding error")
            })
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .eraseToAnyPublisher()
    }
}
