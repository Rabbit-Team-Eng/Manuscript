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

class SignalRManager {
    
    private var connection: HubConnection
    private var cloud: CloudSync
    private var startupUtils: StartupUtils

    init(delegate: HubConnectionDelegate, startupUtils: StartupUtils, cloud: CloudSync) {
        self.cloud = cloud
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
    
    func startListener() {
        connection.on(method: "WorkspaceEntitiesDidChange") { [weak self] (enity: String, id: Int, action: String) in guard let self = self else { return }
            self.cloud.syncronize()
        }
    }
    
    //string enity, long id, string action, List<string> members
    func broadcastMessage(enity: String, id: Int, action: String, members: [String]) {
        DispatchQueue.global(qos: .background).async { [weak self] in guard let self = self else { return }
            self.connection.invoke(method: "WorkspaceEntitiesDidChange", enity, id, action, members) { error in
                if let error = error {
                    print("=================================SignalR Boardcasting Did Fail \(error.localizedDescription)=================================")
                }
            }
        }
    }
    
    deinit {
        print("DEALLOC -> SignalRManager")
    }
}

