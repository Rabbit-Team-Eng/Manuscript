//
//  MemoryLeaksTest.swift
//  ManuscriptTests
//
//  Created by Tigran Ghazinyan on 6/16/22.
//

import XCTest
import Manuscript

class MemoryLeaksTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testDeallocation() {
//        assertDeallocation { () -> Ta in
//            let bucket = Bucket()
//            let viewModel = OwnedBucketViewModel(bucket: bucket)
//            return OwnedBucketViewController(viewModel: viewModel)
//        }
    }

}
//
//extension XCTestCase {
//
//    /// Verifies whether the given constructed UIViewController gets deallocated after being presented and dismissed.
//    ///
//    /// - Parameter testingViewController: The view controller constructor to use for creating the view controller.
//    func assertDeallocation(of testedViewController: () -> UIViewController) {
//        weak var weakReferenceViewController: UIViewController?
//
//        let autoreleasepoolExpectation = expectation(description: "Autoreleasepool should drain")
//        autoreleasepool {
//            let rootViewController = UIViewController()
//
//            // Make sure that the view is active and we can use it for presenting views.
//            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
//            window.rootViewController = rootViewController
//            window.makeKeyAndVisible()
//
//            /// Present and dismiss the view after which the view controller should be released.
//            rootViewController.present(testedViewController(), animated: false, completion: {
//                weakReferenceViewController = rootViewController.presentedViewController
//                XCTAssertNotNil(weakReferenceViewController)
//
//                rootViewController.dismiss(animated: false, completion: {
//                    autoreleasepoolExpectation.fulfill()
//                })
//            })
//        }
//        wait(for: [autoreleasepoolExpectation], timeout: 10.0)
//        wait(for: weakReferenceViewController == nil, timeout: 3.0, description: "The view controller should be deallocated since no strong reference points to it.")
//    }
//}
