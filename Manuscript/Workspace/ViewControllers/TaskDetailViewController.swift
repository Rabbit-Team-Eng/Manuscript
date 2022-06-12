//
//  TaskCreateViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/8/22.
//

import UIKit

enum TaskDetailState {
    case creation
    case edit
}

class TaskDetailViewController: UIViewController, TaskCreateActionProtocol {
    
    weak var coordinator: TabBarCoordinator? = nil

    func actionDidHappen(action: TaskCreateAction) {
        
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<TaskCreateSectionType, TaskCreateCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<TaskCreateSectionType, TaskCreateCellModel>
    
    lazy var dataSource = createDataSource()
    
    let workspace: WorkspaceBusinessModel?
    let boardViewModel: BoardsViewModel
    
    lazy var myColectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = Palette.lightBlack
        return collectionView
    }()

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
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.setTitle("Delete board", for: .normal)
        button.contentHorizontalAlignment = .center
        button.configuration?.baseBackgroundColor = Palette.blue
        button.setTitleColor(Palette.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let taskDetailState: TaskDetailState
    let selectedBoard: BoardBusinessModel?

    init(taskDetailState: TaskDetailState, workspace: WorkspaceBusinessModel?, selectedBoard: BoardBusinessModel?, boardViewModel: BoardsViewModel) {
        self.taskDetailState = taskDetailState
        self.selectedBoard = selectedBoard
        self.workspace = workspace
        self.boardViewModel = boardViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.lightBlack
        
        closeButton.addTarget(self, action: #selector(closeScreen(_:)), for: .touchUpInside)

        view.addSubview(closeButton)
        view.addSubview(titleTexLabel)
        view.addSubview(createNewTaskButton)
        view.addSubview(myColectionView)
        view.addSubview(deleteButton)


        myColectionView.register(TaskGeneralInfoSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TaskGeneralInfoSectionHeaderView.reuseIdentifier)
        
        
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
            
            createNewTaskButton.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -32),
            createNewTaskButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            createNewTaskButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            createNewTaskButton.heightAnchor.constraint(equalToConstant: 50),
            
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            
        ])
        
        
        if taskDetailState == .creation {

        }
        
        if taskDetailState == .edit {

        }
        
        var localSnapshot: [TaskCreateCellModel] = []
        
        
        if let selectedWorkspace = workspace {
            localSnapshot.append(
                TaskCreateCellModel(id: "0",
                                    generalInformationCellModel: TaskGeneralInfoCellModel(title: "",
                                                                                          description: "",
                                                                                          isEditable: true,
                                                                                          needPlaceholders: true)))
            
            selectedWorkspace.boards?.forEach({ board in
                localSnapshot.append(TaskCreateCellModel(id: "\(board.remoteId)",
                                                         boardSelectorCellModel: BoardSelectorCellModel(title: board.title,
                                                                                                        iconResource: board.assetUrl)))

            })
        }
        
        applySnapshot(items: localSnapshot)
        
        
    }
    
    
    func applySnapshot(items: [TaskCreateCellModel], animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.generalInformationSection])
        snapshot.appendSections([.boardSelectorSection])
        
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
    



}

extension TaskDetailViewController {
    
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
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(48))
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
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem])
        layoutGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
        
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
}
