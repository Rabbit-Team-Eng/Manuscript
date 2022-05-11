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
            if state == .didInsertedNewWorkspaceIntoDatabase {
                print("New Workspace was successfully inserted into Local Database!")
            }
        })
        .store(in: &tokens)
        
        view.backgroundColor = UIColor(hex: "#15133C")
        view.addSubview(myColectionView)
        myColectionView.register(SimpleSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SimpleSectionHeaderView.reuseIdentifier)
        
        applySnapshot(items: [
            DatabaseItem(id: "1", title: "Create New Workspace", action: .createNewWorkspace, type: .workspace),
            DatabaseItem(id: "4", title: "Create New Board", action: .createNewWorkspace, type: .board),
        ])

        
    }
    
    func eventDidHappen(action: DatabaseAction) {
        if action == .createNewWorkspace {
            viewModel?.insertNewWorkspacesIntoLocalDatabase()
        }
    }
    
    
    func applySnapshot(items: [DatabaseItem], animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.workspace, .board])
        
        items.forEach { item in
            
            if item.type == .workspace {
                snapshot.appendItems([item], toSection: .workspace)
                return
            }
            
            if item.type == .board {
                snapshot.appendItems([item], toSection: .board)
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
            }
        }
        
        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()
        return layout
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

        let dataSource = DataSource(collectionView: myColectionView) { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier.action {
            case .createNewWorkspace:
                return collectionView.dequeueConfiguredReusableCell(using: singleButtonCellRegistration, for: indexPath, item: itemIdentifier)

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

}





