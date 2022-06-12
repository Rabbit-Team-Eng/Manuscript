//
//  TaskCreateViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/8/22.
//

import UIKit

class TaskCreateViewController: UIViewController, TaskCreateActionProtocol {
    
    weak var coordinator: TabBarCoordinator? = nil

    func actionDidHappen(action: TaskCreateAction) {
        
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<TaskCreateSectionType, TaskCreateCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<TaskCreateSectionType, TaskCreateCellModel>
    
    lazy var dataSource = createDataSource()
    
    func generalInfoCellRegistration() -> UICollectionView.CellRegistration<TaskGeneralInfoCell, TaskCreateCellModel> {
        return .init { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            cell.model = itemIdentifier.generalInformationCellModel
            cell.delegate = self
        }
    }
    
    func boardSelectorCellRegistration() -> UICollectionView.CellRegistration<BoardSelectorCell, TaskCreateCellModel> {
        return .init { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            cell.model = itemIdentifier.boardSelectorCellModel
        }
    }
    
    func createDataSource() -> DataSource {
        let generalInfoCell = generalInfoCellRegistration()
        let manageAccessCell = boardSelectorCellRegistration()
        
        let dataSource = DataSource(collectionView: myColectionView) { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier.section {
            case .generalInformationSection:
                return collectionView.dequeueConfiguredReusableCell(using: generalInfoCell, for: indexPath, item: itemIdentifier)
            case .boardSelectorSection:
                return collectionView.dequeueConfiguredReusableCell(using: manageAccessCell, for: indexPath, item: itemIdentifier)
            default:
                fatalError()
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .generalInformationSection:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskGeneralInfoSectionHeaderView.reuseIdentifier, for: indexPath) as? TaskGeneralInfoSectionHeaderView
                view?.titleLabel.text = section.sectionHeaderTitle
                return view
            case .boardSelectorSection:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskGeneralInfoSectionHeaderView.reuseIdentifier, for: indexPath) as? TaskGeneralInfoSectionHeaderView
                view?.titleLabel.text = section.sectionHeaderTitle
                return view
            default:
                fatalError()

            }
        }
        return dataSource
    }
    
    lazy var myColectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = Palette.lightBlack
        return collectionView
    }()
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in

            guard let self = self else { fatalError() }

            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]

            switch section {
            case .generalInformationSection:
                return self.createGeneralInfoSectionLayout()
            case .boardSelectorSection:
                return self.createBoardSelectorSectionLayout()
            default:
                fatalError()
            }
        }

        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()
        return layout
    }
    
    func createGeneralInfoSectionLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
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
    
    func createBoardSelectorSectionLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(64))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem])
        layoutGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(20))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        sectionHeader.pinToVisibleBounds = true
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.boundarySupplementaryItems = [sectionHeader]
        return layoutSection
    }
    

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.contentHorizontalAlignment = .center
        button.configuration?.baseBackgroundColor = Palette.blue
        button.setTitleColor(Palette.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleTexLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.preferredFont(for: .title2, weight: .bold)
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.text = "Create new Task"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
      
    private let createNewTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.title = "Create New Task"
        button.contentHorizontalAlignment = .center
        button.configuration?.baseBackgroundColor = Palette.blue
        button.setTitleColor(Palette.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.lightBlack
        
        closeButton.addTarget(self, action: #selector(closeScreen(_:)), for: .touchUpInside)

        view.addSubview(closeButton)
        view.addSubview(titleTexLabel)

        view.addSubview(myColectionView)
        view.addSubview(createNewTaskButton)
        

        myColectionView.register(TaskGeneralInfoSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TaskGeneralInfoSectionHeaderView.reuseIdentifier)
        
        applySnapshot(items: [
            TaskCreateCellModel(id: "0", generalInformationCellModel: TaskGeneralInfoCellModel(title: "", description: "", isEditable: true, needPlaceholders: true)),
            TaskCreateCellModel(id: "1", boardSelectorCellModel: BoardSelectorCellModel(title: "Ign", iconResource: "trash")),
            TaskCreateCellModel(id: "2", boardSelectorCellModel: BoardSelectorCellModel(title: "Ign", iconResource: "trash")),
            TaskCreateCellModel(id: "3", boardSelectorCellModel: BoardSelectorCellModel(title: "Ign", iconResource: "trash")),

        
        ])
        
    }
    
    func applySnapshot(items: [TaskCreateCellModel], animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        

        snapshot.appendSections([.generalInformationSection, .boardSelectorSection])

        
        items.forEach { item in
            
            if item.generalInformationCellModel != nil {
                snapshot.appendItems([item], toSection: .generalInformationSection)
            }
            
            if item.boardSelectorCellModel != nil {
                snapshot.appendItems([item], toSection: .boardSelectorSection)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    @objc private func closeScreen(_ sender: UIButton) {
        coordinator?.dismissTaskCreationSheet()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: titleTexLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            
            titleTexLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            titleTexLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTexLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            titleTexLabel.heightAnchor.constraint(equalToConstant: 24),

            myColectionView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            myColectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            myColectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            myColectionView.bottomAnchor.constraint(equalTo: createNewTaskButton.topAnchor, constant: -32),
            
            createNewTaskButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            createNewTaskButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            createNewTaskButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            createNewTaskButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }


}
