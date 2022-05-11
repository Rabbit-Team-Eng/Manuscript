//
//  ServiceViewController.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/9/22.
//

import UIKit

enum Action: Hashable {
    
}
enum Template: Hashable {
    case withInout
    case withoutInput
}

struct Input: Hashable {
    let placeholder: String
    let result: String
}

struct ActionItem: Hashable {
    let id: String
    let title: String
    let action: Action
    let input: Input?
    let template: Template
    
    static func == (lhs: ActionItem, rhs: ActionItem) -> Bool {
        return lhs.id == rhs.id
    }
}

enum Section {
    case main
}

class ServiceViewController: UIViewController {
    
//    typealias DataSource = UICollectionViewDiffableDataSource<Section, ActionItem>
//    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ActionItem>
//
//    lazy var myColectionView: UICollectionView = {
//        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.backgroundColor = UIColor(hex: "#15133C")
//        return collectionView
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#15133C")

    }


}
