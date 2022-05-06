//
//  Coordinator.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

protocol Coordinator: AnyObject {

    var childCoordinators: [Coordinator] { get set }

    func start(with flow: Flowable)

}
