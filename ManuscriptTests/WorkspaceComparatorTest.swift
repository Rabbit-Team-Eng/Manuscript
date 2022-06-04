//
//  WorkspaceComparatorTest.swift
//  ManuscriptTests
//
//  Created by Tigran Ghazinyan on 6/3/22.
//

import XCTest
import Manuscript

class WorkspaceComparatorTest: XCTestCase {
    
    private struct Constants {
        static let IS_NOT_INITIALLY_SYNC = false
        static let IS_SYNCED = true
    }
    
    // User Signed In
    // Local Database has 3 Workspaces
    // We make a call to get all workspaces from the server
    // Get back 5 items becasue from other device we created 2 new Worskpaces
    // Should return 2 with identifier that new workspaces need to be stored locally.
    // CREATE_IN_CORE_DATA
    func testInsertNewWorkspace() throws {
        
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        let januarySecond = "2022-01-02T00:00:00.000000Z"
        
        
        let cachedWorkspaces: [WorkspaceBusinessModel] = [
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "", sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Work",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 2,
                                   title: "Company",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
        ]
        
        let serverWorkspaces: [WorkspaceBusinessModel] = [
            
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Work",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 2,
                                   title: "Company",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 3,
                                   title: "Rabbit New Addition",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 4,
                                   title: "Wolf New Addition",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
        ]
        
        let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)
        
        XCTAssertEqual(2, modificationRequiringWorkspaces.count)

        XCTAssertEqual(.insertion, modificationRequiringWorkspaces[0].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[0].target)
        XCTAssertEqual("Rabbit New Addition", modificationRequiringWorkspaces[0].businessObject.title)

        XCTAssertEqual(.insertion, modificationRequiringWorkspaces[1].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[1].target)
        XCTAssertEqual("Wolf New Addition", modificationRequiringWorkspaces[1].businessObject.title)
        
    }
    
    // User Signed In
    // Local Database has 3 Workspaces
    // We make a call to get all workspaces from the server
    // Get back 3 items with the same IDs that we have in our local database
    // but 2 of them have different Names becasue we renamed them from the Web
    // Should return 2 items with identifier that 2 workspaces need to be renamed locally
    // UPDATE_IN_CORE_DATA
    func testUpdateLocalStorage() throws {
        
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        let januarySecond = "2022-01-02T00:00:00.000000Z"
        
        let cachedWorkspaces: [WorkspaceBusinessModel] = [
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Work",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 2,
                                   title: "Company",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false)
        ]
        
        let serverWorkspaces: [WorkspaceBusinessModel] = [
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Work (Renamed)",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 2,
                                   title: "Company (Renamed)",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false)
        ]
        
        let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)
        
        XCTAssertEqual(2, modificationRequiringWorkspaces.count)
        
        XCTAssertEqual(.update, modificationRequiringWorkspaces[0].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[0].target)
        XCTAssertEqual("Company (Renamed)", modificationRequiringWorkspaces[0].businessObject.title)
        
        XCTAssertEqual(.update, modificationRequiringWorkspaces[1].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[1].target)
        XCTAssertEqual("Work (Renamed)", modificationRequiringWorkspaces[1].businessObject.title)
    }
    
    // User Signed In
    // Local Database has 3 Workspaces
    // We make a call to get all workspaces from the server
    // Get back 4 items, 3 workspaces with the same IDs that we have in our local database
    // but 2 of them have different Names becasue we renamed them from the Web
    // Should return 3 items. 1 of them with insertion operation another 2 with update.
    // 2 items - UPDATE_IN_CORE_DATA |
    // 1 item - CREATE_IN_CORE_DATA
    func testAreNewWorkspacesAndNewUpdates() throws {
        
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        let januarySecond = "2022-01-02T00:00:00.000000Z"
        
        let cachedWorkspaces: [WorkspaceBusinessModel] = [
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Work",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 2,
                                   title: "Company",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false)
        ]
        
        let serverWorkspaces: [WorkspaceBusinessModel] = [
            
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Work (Renamed)",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 2,
                                   title: "Company (Renamed)",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 3,
                                   title: "Rabit (New Added)",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false)
        ]
        
        let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)

        XCTAssertEqual(3, modificationRequiringWorkspaces.count)

        XCTAssertEqual(.insertion, modificationRequiringWorkspaces[0].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[0].target)
        XCTAssertEqual("Rabit (New Added)", modificationRequiringWorkspaces[0].businessObject.title)
        XCTAssertEqual(3, modificationRequiringWorkspaces[0].businessObject.remoteId)
        
        XCTAssertEqual(.update, modificationRequiringWorkspaces[1].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[1].target)
        XCTAssertEqual("Company (Renamed)", modificationRequiringWorkspaces[1].businessObject.title)

        
        XCTAssertEqual(.update, modificationRequiringWorkspaces[2].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[2].target)
        XCTAssertEqual("Work (Renamed)", modificationRequiringWorkspaces[2].businessObject.title)
    }
    
    // New User registered
    // Created 3 new workspaces
    // No Internet, saved locally in Core Data
    // Kill the app
    // User reopens the app
    // We make a call to get all workspaces
    // Get empty collection as this is new user and have only locally saved workspaces
    // Should return 3 items with identifier that new workspaces are available only
    // locally and we need to make POST request to save the in the Server.
    // 3 items - INSERTION_IN_SERVER |
    func testNewLocalWorkspacesButNotPostedInTheServer() throws {
        
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        
        let cachedWorkspaces: [WorkspaceBusinessModel] = [
            
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_NOT_INITIALLY_SYNC,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Work",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_NOT_INITIALLY_SYNC,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 2,
                                   title: "Company",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_NOT_INITIALLY_SYNC,
                                   isPendingDeletionOnTheServer: false)
        ]
        
        let serverWorkspaces: [WorkspaceBusinessModel] = [
        ]
        
        let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)
        
        XCTAssertEqual(3, modificationRequiringWorkspaces.count)
        XCTAssertEqual(.insertion, modificationRequiringWorkspaces[0].operation)
        XCTAssertEqual(.server, modificationRequiringWorkspaces[0].target)

        XCTAssertEqual(.insertion, modificationRequiringWorkspaces[1].operation)
        XCTAssertEqual(.server, modificationRequiringWorkspaces[1].target)

        XCTAssertEqual(.insertion, modificationRequiringWorkspaces[2].operation)
        XCTAssertEqual(.server, modificationRequiringWorkspaces[2].target)
    }
    
    // User Signed In
    // Local Database has 3 Workspaces
    // We make a call to get all workspaces from the server
    // Get back empty collection beause the user removed evrything from other device
    // Should return 3 items. 3 of them identifying that need to be removed
    // 3 items - REMOVE_IN_CORE_DATA |
    func testRemoveLocalWorkspacesDeletedInServer() throws {
        
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        
        let cachedWorkspaces: [WorkspaceBusinessModel] = [
            
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Work",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 2,
                                   title: "Company",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false)
        ]
        
        let serverWorkspaces: [WorkspaceBusinessModel] = [
        ]
        
        let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)
        
        XCTAssertEqual(3, modificationRequiringWorkspaces.count)
        XCTAssertEqual(.removal, modificationRequiringWorkspaces[0].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[0].target)

        XCTAssertEqual(.removal, modificationRequiringWorkspaces[1].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[1].target)

        XCTAssertEqual(.removal, modificationRequiringWorkspaces[2].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[2].target)
        
    }
    
    func testRemoveLocalWorkspacesDeletedInServerAddOneUpdateOne() throws {
        
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        let januarySecond = "2022-01-02T00:00:00.000000Z"
        
        let cachedWorkspaces: [WorkspaceBusinessModel] = [
            
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Work",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 2,
                                   title: "Company",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false)
        ]
        
        let serverWorkspaces: [WorkspaceBusinessModel] = [
            
            WorkspaceBusinessModel(remoteId: 2,
                                   title: "Company (Renamed)",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 3,
                                   title: "Rabbit (New Added)",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false)
            
        ]
        
        let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)
        
        XCTAssertEqual(4, modificationRequiringWorkspaces.count)
        XCTAssertEqual(.insertion, modificationRequiringWorkspaces[0].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[0].target)
        XCTAssertEqual("Rabbit (New Added)", modificationRequiringWorkspaces[0].businessObject.title)

        XCTAssertEqual(.update, modificationRequiringWorkspaces[1].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[1].target)
        XCTAssertEqual("Company (Renamed)", modificationRequiringWorkspaces[1].businessObject.title)

        XCTAssertEqual(.removal, modificationRequiringWorkspaces[2].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[2].target)

        
    }
    
    func testUpdateOnTheServerDiff() throws {
        
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        let januarySecond = "2022-01-02T00:00:00.000000Z"
        
        let cachedWorkspaces: [WorkspaceBusinessModel] = [
            
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
        ]
        
        let serverWorkspaces: [WorkspaceBusinessModel] = [
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
        ]
        
        let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)
        
        XCTAssertEqual(1, modificationRequiringWorkspaces.count)
        XCTAssertEqual(.update, modificationRequiringWorkspaces[0].operation)
        XCTAssertEqual(.server, modificationRequiringWorkspaces[0].target)
    }
    
    func testDateLogic() throws {
        
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        let januarySecond = "2022-01-02T00:00:00.000000Z"
        
        let cachedWorkspaces: [WorkspaceBusinessModel] = [
            
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
        ]
        
        let serverWorkspaces: [WorkspaceBusinessModel] = [
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
        ]
        
        let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)
        
        XCTAssertEqual(1, modificationRequiringWorkspaces.count)
        XCTAssertEqual(.update, modificationRequiringWorkspaces[0].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[0].target)
        
        
    }
    
    func testAdditionRemovalUpdate() {
        
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        let januarySecond = "2022-01-02T00:00:00.000000Z"
        
        let cachedWorkspaces: [WorkspaceBusinessModel] = [
            
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_NOT_INITIALLY_SYNC,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Workspace",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 2,
                                   title: "Rabbit (Renamed)",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 4,
                                   title: "Should Be Removed Workspaces",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
        ]
        
        let serverWorkspaces: [WorkspaceBusinessModel] = [
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Workspace",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 2,
                                   title: "Rabbit",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 3,
                                   title: "Yard",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
        ]
        
        let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)
        
        XCTAssertEqual(5, modificationRequiringWorkspaces.count)
        
        XCTAssertEqual("Yard", modificationRequiringWorkspaces[0].businessObject.title)
        XCTAssertEqual(.insertion, modificationRequiringWorkspaces[0].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[0].target)
        XCTAssertEqual(DateTimeUtils.convertServerStringToDate(stringDate: januaryOne), modificationRequiringWorkspaces[0].businessObject.lastModifiedDate)
        
        XCTAssertEqual("Should Be Removed Workspaces", modificationRequiringWorkspaces[1].businessObject.title)
        XCTAssertEqual(.removal, modificationRequiringWorkspaces[1].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[1].target)
        XCTAssertEqual(DateTimeUtils.convertServerStringToDate(stringDate: januarySecond), modificationRequiringWorkspaces[1].businessObject.lastModifiedDate)
        
        XCTAssertEqual("Rabbit (Renamed)", modificationRequiringWorkspaces[2].businessObject.title)
        XCTAssertEqual(.update, modificationRequiringWorkspaces[2].operation)
        XCTAssertEqual(.server, modificationRequiringWorkspaces[2].target)
        XCTAssertEqual(DateTimeUtils.convertServerStringToDate(stringDate: januarySecond), modificationRequiringWorkspaces[2].businessObject.lastModifiedDate)
        
        XCTAssertEqual("Workspace", modificationRequiringWorkspaces[3].businessObject.title)
        XCTAssertEqual(.update, modificationRequiringWorkspaces[3].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[3].target)
        XCTAssertEqual(DateTimeUtils.convertServerStringToDate(stringDate: januarySecond), modificationRequiringWorkspaces[3].businessObject.lastModifiedDate)
        
        XCTAssertEqual("Personal", modificationRequiringWorkspaces[4].businessObject.title)
        XCTAssertEqual(.insertion, modificationRequiringWorkspaces[4].operation)
        XCTAssertEqual(.server, modificationRequiringWorkspaces[4].target)
        XCTAssertEqual(DateTimeUtils.convertServerStringToDate(stringDate: januaryOne), modificationRequiringWorkspaces[4].businessObject.lastModifiedDate)
    }
    
    func testManyWorkspaces() {
        var cachedWorkspaces: [WorkspaceBusinessModel] = []
        var serverWorkspaces: [WorkspaceBusinessModel] = []
        
        (0...500).forEach { i in
            cachedWorkspaces.append(WorkspaceBusinessModel(
                remoteId: i,
                title: "d",
                mainDescription: "d",
                sharingEnabled: false,
                lastModifiedDate: "2022-01-01T00:00:00.000000Z",
                isInitiallySynced: true,
                isPendingDeletionOnTheServer: false)
            )
        }
        
        (0...1000).forEach { i in
            serverWorkspaces.append(WorkspaceBusinessModel(
                remoteId: i,
                title: "d",
                mainDescription: "d",
                sharingEnabled: false,
                lastModifiedDate: "2022-01-01T00:00:00.000000Z",
                isInitiallySynced: true,
                isPendingDeletionOnTheServer: false)
            )
        }

        measure {
            let startDiffing = CFAbsoluteTimeGetCurrent()
            let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)
            let finishDiffing = CFAbsoluteTimeGetCurrent() - startDiffing
            print("Took \(finishDiffing) seconds")
            XCTAssertEqual(500, modificationRequiringWorkspaces.count)
        }


    }
    
    func testNoDifference() {
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        let januarySecond = "2022-01-02T00:00:00.000000Z"
        
        let cachedWorkspaces: [WorkspaceBusinessModel] = [
            
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
        ]
        
        let serverWorkspaces: [WorkspaceBusinessModel] = [
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
        ]
        
        let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)
        
        XCTAssertEqual(0, modificationRequiringWorkspaces.count)
        
    }
    
    func testSimpleDifference() {
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        let januarySecond = "2022-01-02T00:00:00.000000Z"
        
        let cachedWorkspaces: [WorkspaceBusinessModel] = [
            
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
        ]
        
        let serverWorkspaces: [WorkspaceBusinessModel] = [
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Personal (NEw)",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januarySecond,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
        ]
        
        let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)
        XCTAssertEqual(1, modificationRequiringWorkspaces.count)
        XCTAssertEqual("Personal (NEw)", modificationRequiringWorkspaces[0].businessObject.title)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[0].target)
        XCTAssertEqual(.update, modificationRequiringWorkspaces[0].operation)
    }
    
    func testPendingServerDeletion() {
        
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        let januarySecond = "2022-01-02T00:00:00.000000Z"
        
        let cachedWorkspaces: [WorkspaceBusinessModel] = [
            
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
            
            WorkspaceBusinessModel(remoteId: 1,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: true),
        ]
        
        let serverWorkspaces: [WorkspaceBusinessModel] = [
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false)
        ]
        
        let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)
        XCTAssertEqual(1, modificationRequiringWorkspaces.count)
        XCTAssertEqual(.removal, modificationRequiringWorkspaces[0].operation)
        XCTAssertEqual(.server, modificationRequiringWorkspaces[0].target)

    }
    
    func testFoo() {
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        let januarySecond = "2022-01-02T00:00:00.000000Z"
        
        let cachedWorkspaces: [WorkspaceBusinessModel] = [
            
            WorkspaceBusinessModel(remoteId: 0,
                                   title: "Personal (new)",
                                   mainDescription: "",
                                   sharingEnabled: false,
                                   lastModifiedDate: januaryOne,
                                   isInitiallySynced: Constants.IS_SYNCED,
                                   isPendingDeletionOnTheServer: false),
        ]
        
        let serverWorkspaces: [WorkspaceBusinessModel] = [

        ]
        
        let modificationRequiringWorkspaces = WorkspaceComparator.compare(responseCollection: serverWorkspaces, cachedCollection: cachedWorkspaces)
        
        XCTAssertEqual(1, modificationRequiringWorkspaces.count)
        XCTAssertEqual(.removal, modificationRequiringWorkspaces[0].operation)
        XCTAssertEqual(.local, modificationRequiringWorkspaces[0].target)

    }
}
