//
//  SignalRManager.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/16/22.
//

import SignalRClient
import UIKit
import Combine

class SignalRConnectionListener: HubConnectionDelegate {
    
    func connectionDidOpen(hubConnection: HubConnection) {
        print("=================================SignalR Connection Did Open \(hubConnection)=================================")
    }
    
    func connectionDidFailToOpen(error: Error) {
        print(error)

    }
    
    func connectionDidClose(error: Error?) {
        print(error)

    }
        
    deinit {
        print("DEALLOC -> SignalRConnectionListener")
    }
    
}

enum SignalREvent {
    case board
    case workspace
    case task
}

enum SignalRCompletionEvent {
    case success
    case error(description: String)
}

enum SignalRMethod {
    case workspaceEntitiesDidChange
    
    func value() -> String {
        switch self {
        case .workspaceEntitiesDidChange:
            return "WorkspaceEntitiesDidChange"
        }
    }
}

class SignalRManager {
    
    private var connection: HubConnection
    private var startupUtils: StartupUtils
    var workspaceEntitiesDidChangePublisher: PassthroughSubject<SignalREvent, Never> = PassthroughSubject()

    init(delegate: HubConnectionDelegate, startupUtils: StartupUtils) {
        self.startupUtils = startupUtils
        
        let endpoint = "https://api.tasky.space/EntityDidChange"
        connection = HubConnectionBuilder(url: URL(string: endpoint)!)
            .withHttpConnectionOptions(configureHttpOptions: { httpConnectionOptions in
                httpConnectionOptions.accessTokenProvider = {
                    return startupUtils.getAccessToken()
                }
            })
            .withHubConnectionDelegate(delegate: delegate)
            .withAutoReconnect()
            .build()
    }
    
    func startConnection() {
        connection.start()
    }
    
    func stopConnection() {
        connection.stop()
    }
    
    func startListenningToHub(method: SignalRMethod) {
        
        if case .workspaceEntitiesDidChange = method {
            connection.on(method: SignalRMethod.workspaceEntitiesDidChange.value()) { [weak self] (enity: String, id: Int, action: String) in
                guard let self = self else { return }
                self.workspaceEntitiesDidChangePublisher.send(.board)
            }
        }
    }
    
    func notifyMembers(signalREvent: SignalREvent, toMembers: [MemberBusinessModel], completion: @escaping (SignalRCompletionEvent) -> Void) {
        connection.invoke(method: "WorkspaceEntitiesDidChange", "entity", 0, "create", toMembers.map { $0.remoteId }) { error in
            if let error = error {
                completion(.error(description: error.localizedDescription))
            } else {
                completion(.success)
            }
        }
    }
    
    deinit {
        print("DEALLOC -> SignalRManager")
    }
}

