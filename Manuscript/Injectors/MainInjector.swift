//
//  MainInjector.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class MainInjector {

    func provideBoardsTabBarItem() -> UITabBarItem {
        return UITabBarItem(title: "Boards", image: UIImage(systemName: "checkerboard.rectangle"), selectedImage: UIImage(systemName: "checkerboard.rectangle"))
    }

    func provideTasksTabBarItem() -> UITabBarItem {
        return UITabBarItem(title: "Tasks", image: UIImage(systemName: "square.and.pencil"), selectedImage: UIImage(systemName: "square.and.pencil"))
    }

    init() {
        print("AVERAKEDABRA: ALLOC -> MainComponent")
    }

    deinit {
        print("AVERAKEDABRA: RELEASE -> MainComponent")
    }
}
