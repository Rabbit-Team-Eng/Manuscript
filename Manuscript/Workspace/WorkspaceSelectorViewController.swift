//
//  WorkspaceSelectorViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/5/22.
//

import UIKit

class WorkspaceSelectorViewController: UIViewController, WorkspaceSelectorProtocol {
    
    typealias DataSource = UICollectionViewDiffableDataSource<WorkspaceSelectorSectionType, WorkspaceSelectorCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<WorkspaceSelectorSectionType, WorkspaceSelectorCellModel>

    lazy var dataSource = createDataSource()

    weak var parentCoordinator: TabBarCoordinator? = nil

    private let createNewWorkspaceButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.title = "Create new space"
        button.configuration?.image = UIImage(systemName: "plus.square")
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 8
        button.contentHorizontalAlignment = .left
        button.setTitleColor(Palette.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // TODO: Check how to avoid lazy
    private lazy var myColectionView: UICollectionView = {
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        layoutConfig.showsSeparators = false
        layoutConfig.backgroundColor = Palette.lightBlack
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        let collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: listLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let switchWorkspaceButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.title = "Switch to selected space"
        button.contentHorizontalAlignment = .center
        button.configuration?.baseBackgroundColor = Palette.blue
        button.setTitleColor(Palette.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.lightBlack
        view.addSubview(createNewWorkspaceButton)
        view.addSubview(myColectionView)
        view.addSubview(switchWorkspaceButton)
        
        applySnapshot(items: [
            WorkspaceSelectorCellModel(id: "0", title: "abrahamr 0", isEditable: false),
            WorkspaceSelectorCellModel(id: "1", title: "abrahamr 1", isEditable: false),
            WorkspaceSelectorCellModel(id: "2", title: "abrahamr 2", isEditable: false),
            WorkspaceSelectorCellModel(id: "3", title: "abrahamr 3", isEditable: false),
            WorkspaceSelectorCellModel(id: "4", title: "abrahamr 4", isEditable: true),
            WorkspaceSelectorCellModel(id: "5", title: "abrahamr 5", isEditable: false),
            WorkspaceSelectorCellModel(id: "6", title: "abrahamr 6", isEditable: false),
            WorkspaceSelectorCellModel(id: "7", title: "abrahamr 7", isEditable: false),
            WorkspaceSelectorCellModel(id: "8", title: "abrahamr 8", isEditable: false),
            WorkspaceSelectorCellModel(id: "9", title: "abrahamr 9", isEditable: false),
            WorkspaceSelectorCellModel(id: "10", title: "abrahamr 10", isEditable: false),

        ], withAnimation: true)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate([
            createNewWorkspaceButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            createNewWorkspaceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createNewWorkspaceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createNewWorkspaceButton.heightAnchor.constraint(equalToConstant: 20),
            
            myColectionView.topAnchor.constraint(equalTo: createNewWorkspaceButton.bottomAnchor, constant: 32),
            myColectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            myColectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            myColectionView.bottomAnchor.constraint(equalTo: switchWorkspaceButton.topAnchor, constant: -32),

            switchWorkspaceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            switchWorkspaceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            switchWorkspaceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            switchWorkspaceButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func applySnapshot(items: [WorkspaceSelectorCellModel], withAnimation: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: withAnimation)
    }
    
    private func createDataSource() -> DataSource {
        let cell = workspaceSelectorCellRegistration()
        
        let dataSource = DataSource(collectionView: myColectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
            return cell
        }
            
        
        return dataSource
    }
    
    private func workspaceSelectorCellRegistration() -> UICollectionView.CellRegistration<WorkspaceSelectorCell, WorkspaceSelectorCellModel> {
        return .init { [weak self] cell, indexPath, itemIdentifier in
            let config = WorkspaceSelectorContentConfiguration(model: itemIdentifier, delegate: self)
            cell.contentConfiguration = config
        }
    }
    
    func workspaceDidSelected(model: WorkspaceSelectorCellModel) {
        print(model)
    }

}
