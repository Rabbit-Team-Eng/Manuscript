//
//  TaskComparatorTest.swift
//  ManuscriptTests
//
//  Created by Tigran Ghazinyan on 6/13/22.
//

import XCTest
import Manuscript

class TaskComparatorTest: XCTestCase {

    func testInsertionNewFromRemote() throws {
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        let januarySecond = "2023-01-02T00:00:00.000000Z"
        
        let localTasks: [TaskBusinessModel] = []
        let serverTasks: [TaskBusinessModel] = [
        
            TaskBusinessModel(remoteId: 53,
                              assigneeUserId: "6999d838-3c05-4520-96b3-6dc0db5d1e1d",
                              title: "Some other task",
                              detail: "Nothing to do :) ",
                              dueDate: januarySecond,
                              ownerBoardId: 2,
                              status: "new",
                              workspaceId: 426,
                              lastModifiedDate: januaryOne,
                              isInitiallySynced: true,
                              isPendingDeletionOnTheServer: false,
                              priority: .low)
        
        ]
        
        let modificationRequiringTask = TaskComparator.compare(responseCollection: serverTasks, cachedCollection: localTasks)
        
        XCTAssertEqual(1, modificationRequiringTask.count)
        
        XCTAssertEqual(.insertion, modificationRequiringTask[0].operation)
        XCTAssertEqual(.local, modificationRequiringTask[0].target)

      
    }
    
    func testNoChange() throws {
        let januaryOne = "2022-01-01T00:00:00.000000Z"
        let januarySecond = "2023-01-02T00:00:00.000000Z"
        
        let localTasks: [TaskBusinessModel] = []
        let serverTasks: [TaskBusinessModel] = [
        
            TaskBusinessModel(remoteId: 58,
                              assigneeUserId: "im idin",
                              title: "Go to school",
                              detail: "Som decription",
                              dueDate: januarySecond,
                              ownerBoardId: 432,
                              status: "new",
                              workspaceId: 495,
                              lastModifiedDate: januaryOne,
                              isInitiallySynced: true,
                              isPendingDeletionOnTheServer: false,
                              priority: .low)
        
        ]
        
        let modificationRequiringTask = TaskComparator.compare(responseCollection: serverTasks, cachedCollection: localTasks)
        
        XCTAssertEqual(1, modificationRequiringTask.count)
        
        XCTAssertEqual(.insertion, modificationRequiringTask[0].operation)
        XCTAssertEqual(.local, modificationRequiringTask[0].target)

      
    }


}
