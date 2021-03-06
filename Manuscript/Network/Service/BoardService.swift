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
    
    public func createNewBoard(requestBody: BoardRequest) -> AnyPublisher<BoardResponse, Error> {

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
    
    public func getAllBoards() -> AnyPublisher<AllBoardsResponse, Error> {

        let request = GetAllBoardsRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getAllBoards())
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
    
    public func getAllBoardsBusinessModel() -> AnyPublisher<[BoardBusinessModel], SyncError> {

        let request = GetAllBoardsRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getAllBoards())
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                return element.data
            }
            .decode(type: AllBoardsResponse.self, decoder: jsonDecoder)
            .mapError({ error in
                return SyncError.board
            })
            .map { response in
                let boards = response.items
                var ret: [BoardBusinessModel] = []
                boards.forEach { response in
                    ret.append(BoardBusinessModel(remoteId: Int64(response.id),
                                                  title: response.title,
                                                  detailDescription: response.mainDescription ?? "null", assetUrl: response.assetUrl ?? "",
                                                  ownerWorkspaceId: Int64(response.workspaceId),
                                                  lastModifiedDate: response.lastModifiedDate,
                                                  isInitiallySynced: true,
                                                  isPendingDeletionOnTheServer: false))
                }
                return ret
            }

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
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .eraseToAnyPublisher()
    }
    
    public func updateBoardById(requestBody: BoardRequest, boardId: Int64) -> AnyPublisher<BoardResponse, Error> {
        
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
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .eraseToAnyPublisher()
    }
    
    public func deleteBoardById(boardId: Int64) -> AnyPublisher<Int, Error> {
        
        let request = DeleteBoardRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getRequest(boardId: boardId))
            .tryMap() { element -> Int in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                
                return httpResponse.statusCode
            }
            .mapError({ error in
                return BoardError.unableToDecodeResponse(errorMessage: "Decoding error")
            })
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .eraseToAnyPublisher()
    }
}
