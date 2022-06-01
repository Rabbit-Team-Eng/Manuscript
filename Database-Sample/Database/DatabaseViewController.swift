//
//  DatabaseViewController.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import UIKit
import Combine

class DatabaseViewController: UIViewController, DatabaseEventProtocol {
    
    typealias DataSource = UICollectionViewDiffableDataSource<DatabaseSectionType, DatabaseItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<DatabaseSectionType, DatabaseItem>
    
    private var viewModel: DatabaseViewModel? = nil
    private var tokens: Set<AnyCancellable> = []

    lazy var myColectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(hex: "#15133C")
        return collectionView
    }()
    
    lazy var dataSource = createDataSource()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let coreDataStack = CoreDataStack()
        let workspaceCoreDataManager = WorkspaceCoreDataManager(coreDataStack: coreDataStack)
        viewModel = DatabaseViewModel(workspaceCoreDataManager: workspaceCoreDataManager)
        
        viewModel?.state.sink(receiveCompletion: { completion in }, receiveValue: { state in
            switch state {
            case .didInsertedNewWorkspaceIntoDatabase:
                print("New Workspace was successfully inserted into Local Database!")
            case .didFetchWorkspaceById(let workspace):
                self.showAlert(title: "Workspace", message: "\(workspace)")
                print("The fetched workspace is: \(workspace.remoteId) | \(workspace)")
            }

        })
        .store(in: &tokens)
        
        view.backgroundColor = UIColor(hex: "#15133C")
        view.addSubview(myColectionView)
        myColectionView.register(SimpleSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SimpleSectionHeaderView.reuseIdentifier)
        myColectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        applySnapshot(items: [
            DatabaseItem(id: "1", title: "Create New Workspace", type: .workspace, entityType: .workspace),
            DatabaseItem(id: "4", title: "Create New Board", type: .board, entityType: .board),
            DatabaseItem(id: "5", title: "Update Workspace By ID", type: .input, entityType: .workspace),
            DatabaseItem(id: "5", title: "Update Board By ID", type: .input, entityType: .board),
            DatabaseItem(id: "5", title: "Update Task By ID", type: .input, entityType: .task),
            DatabaseItem(id: "6", title: "Get Workspace by ID", type: .fetcher, entityType: .workspace),


        ])

        
        
    }
    
//    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.frame.origin.y == 0 {
//                self.frame.origin.y -= keyboardSize.height - 0
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if self.frame.origin.y != 0 {
//            self.frame.origin.y = 0
//        }
//    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func eventDidHappen(action: DatabaseAction) {
        
        switch action {
        case .createNewWorkspace:
            viewModel?.insertNewWorkspacesIntoLocalDatabase()
        case .updateWorkspaceById(let id, let newTitle, let entityType):
            print("The Id is \(id), the new title is: \(newTitle), the type is: \(entityType)")
        case .updateBoardById:
            fatalError()
        case .updateTaskById:
            fatalError()
        case .printEntityById(id: let id, entity: let entity):
            print("The Id is \(id), the type is: \(entity)")
            viewModel?.fetchWorkspaceById(id: Int(id)!)
        }

    }
    
    
    func applySnapshot(items: [DatabaseItem], animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.workspace, .board, .input, .fetcher])
        
        items.forEach { item in
            
            if item.type == .workspace {
                snapshot.appendItems([item], toSection: .workspace)
                return
            }
            
            if item.type == .board {
                snapshot.appendItems([item], toSection: .board)
                return
            }
            
            if item.type == .input {
                snapshot.appendItems([item], toSection: .input)
                return
            }
            
            if item.type == .fetcher {
                snapshot.appendItems([item], toSection: .fetcher)
                return
            }

        }
        
        self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]

            switch section {
            case .workspace:
                return self.createSingleButtonSectionLayout()
            case .board:
                return self.createSingleButtonSectionLayout()
            case .input:
                return self.createFieldButtonSectionLayout()
            case .fetcher:
                return self.createSingleInputFieldButtonSectionLayout()
            }
        }
        
        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()
        return layout
    }
    func createSingleInputFieldButtonSectionLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(104))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        

        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        
        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(30)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        sectionHeader.pinToVisibleBounds = true
        layoutSection.boundarySupplementaryItems = [sectionHeader]
        return layoutSection
    }
    
    func createFieldButtonSectionLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(152))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        

        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        
        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(30)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        sectionHeader.pinToVisibleBounds = true
        layoutSection.boundarySupplementaryItems = [sectionHeader]
        return layoutSection
    }
    
    func createSingleButtonSectionLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(56))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        
        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(30)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        sectionHeader.pinToVisibleBounds = true
        layoutSection.boundarySupplementaryItems = [sectionHeader]
        return layoutSection
    }
    
    func createDataSource() -> DataSource {
        let singleButtonCellRegistration = singleButtonCellRegistration()
        let fieldButtonCellRegistration = fieldButtonCellRegistration()
        let inputFieldButtonRegisration = singleInputFieldButtonCellRegistration()
        
        let dataSource = DataSource(collectionView: myColectionView) { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier.type {
            case .workspace:
                return collectionView.dequeueConfiguredReusableCell(using: singleButtonCellRegistration, for: indexPath, item: itemIdentifier)

            case .board:
                return collectionView.dequeueConfiguredReusableCell(using: singleButtonCellRegistration, for: indexPath, item: itemIdentifier)
                
            case .input:
                return collectionView.dequeueConfiguredReusableCell(using: fieldButtonCellRegistration, for: indexPath, item: itemIdentifier)
            case .fetcher:
                return collectionView.dequeueConfiguredReusableCell(using: inputFieldButtonRegisration, for: indexPath, item: itemIdentifier)
            }
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .workspace:
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SimpleSectionHeaderView.reuseIdentifier,
                    for: indexPath) as? SimpleSectionHeaderView
                view?.titleLabel.text = "Workspaces"
                return view

            case .board:
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SimpleSectionHeaderView.reuseIdentifier,
                    for: indexPath) as? SimpleSectionHeaderView
                view?.titleLabel.text = "Boards"
                return view
            case .input:
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SimpleSectionHeaderView.reuseIdentifier,
                    for: indexPath) as? SimpleSectionHeaderView
                view?.titleLabel.text = "Update Entity with ID"
                return view
            case .fetcher:
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SimpleSectionHeaderView.reuseIdentifier,
                    for: indexPath) as? SimpleSectionHeaderView
                view?.titleLabel.text = "Fetchers"
                return view
            }
        }
        return dataSource
        
    }
    
    func singleButtonCellRegistration() -> UICollectionView.CellRegistration<SingleButtonCell, DatabaseItem> {
        return .init { cell, indexPath, itemIdentifier in
            cell.model = itemIdentifier
            cell.delegate = self
        }
    }
    
    func fieldButtonCellRegistration() -> UICollectionView.CellRegistration<FieldButtonCell, DatabaseItem> {
        return .init { cell, indexPath, itemIdentifier in
            cell.model = itemIdentifier
            cell.delegate = self
        }
    }
    
    func singleInputFieldButtonCellRegistration() -> UICollectionView.CellRegistration<SingleInputFieldButtonCell, DatabaseItem> {
        return .init { cell, indexPath, itemIdentifier in
            cell.model = itemIdentifier
            cell.delegate = self
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
        self.present(alert, animated: true, completion: nil)
    }

}





