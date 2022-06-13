//
//  TaskCreateViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/8/22.
//

import UIKit
import Combine

enum TaskDetailState {
    case creation
    case edit
}

class TaskDetailViewController: UIViewController, TaskDetailActionProtocol {
    
    weak var coordinator: TabBarCoordinator? = nil

    func actionDidHappen(action: TaskDetailAction) {
        
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<TaskDetailSectionType, TaskDetailCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<TaskDetailSectionType, TaskDetailCellModel>
    
    lazy var dataSource = createDataSource()
    
    let workspace: WorkspaceBusinessModel?
    let boardViewModel: BoardsViewModel
    var tokens: Set<AnyCancellable> = []
    
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
        button.setTitle("Delete Task", for: .normal)
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
        
        boardViewModel.priorirtySetEvenet.sink { completion in } receiveValue: { [weak self] priority in guard let self = self else { return }
            
            var newSnapshot = self.dataSource.snapshot().itemIdentifiers.filter { $0.section != .prioritySection }
            
            if priority == .low {
                newSnapshot.append(
                    TaskDetailCellModel(id: "0", priorityCellModel: PrioritySelectorCellModel(title: "Low",
                                                                                              description: "Low priority task which will go to the end of your task list",
                                                                                              priority: .low,
                                                                                              isHighlighted: true))
                
                )
                
            } else if priority == .medium {
                newSnapshot.append(
                    TaskDetailCellModel(id: "1", priorityCellModel: PrioritySelectorCellModel(title: "Medium",
                                                                                              description: "Medium priority is a regular task which will be in your task list",
                                                                                              priority: .medium,
                                                                                              isHighlighted: true))
                
                )
                
            } else if priority == .high {
                newSnapshot.append(
                    TaskDetailCellModel(id: "2", priorityCellModel: PrioritySelectorCellModel(title: "High",
                                                                                              description: "High priority task will go to top of your list and you will get notifications frequently",
                                                                                              priority: .high,
                                                                                              isHighlighted: true))
                
                )
                
            }

            
            self.applySnapshot(items: newSnapshot)

            
            
        }
        .store(in: &tokens)

        
        view.backgroundColor = Palette.lightBlack
        
        closeButton.addTarget(self, action: #selector(closeScreen(_:)), for: .touchUpInside)

        view.addSubview(closeButton)
        view.addSubview(titleTexLabel)
        view.addSubview(createNewTaskButton)
        view.addSubview(myColectionView)
        view.addSubview(deleteButton)
        
        createNewTaskButton.addTarget(self, action: #selector(createNewTaskButtonDidTap(_:)), for: .touchUpInside)

        myColectionView.delegate = self
        myColectionView.register(TaskGeneralInfoSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TaskGeneralInfoSectionHeaderView.reuseIdentifier)
        
        let creationConstraints = [
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
            createNewTaskButton.heightAnchor.constraint(equalToConstant: 50)
            
        ]
        
        let editConstraints = [
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
            
        ]
        
        
        if taskDetailState == .creation {
//            NSLayoutConstraint.activate(creationConstraints)
            NSLayoutConstraint.activate(editConstraints)
//            deleteButton.removeFromSuperview()
        }
        
        if taskDetailState == .edit {
            NSLayoutConstraint.activate(editConstraints)

        }
        
        var localSnapshot: [TaskDetailCellModel] = []
        
        
        if let selectedWorkspace = workspace, let board = selectedBoard {
            localSnapshot.append(
                TaskDetailCellModel(id: "0",
                                    generalInformationCellModel: TaskGeneralInfoCellModel(title: "",
                                                                                          description: "",
                                                                                          isEditable: true,
                                                                                          needPlaceholders: true)))
            
            let selectedBoard  = TaskDetailCellModel(id: "\(board.remoteId)",
                                                     boardSelectorCellModel: BoardSelectorCellModel(title: board.title,
                                                                                                    iconResource: board.assetUrl))
            localSnapshot.append(contentsOf: [selectedBoard])

            if let otherBoards = selectedWorkspace.boards?.filter({ "\($0.remoteId)" != "\(selectedBoard.id)"}).map({ board in
                TaskDetailCellModel(id: "\(board.remoteId)",
                                    boardSelectorCellModel: BoardSelectorCellModel(title: board.title,
                                                                                   iconResource: board.assetUrl))
            }) {
                localSnapshot.append(contentsOf: otherBoards)
            }
            
            
            

        } else {
            localSnapshot.append(
                TaskDetailCellModel(id: "0",
                                    generalInformationCellModel: TaskGeneralInfoCellModel(title: "",
                                                                                          description: "",
                                                                                          isEditable: true,
                                                                                          needPlaceholders: true)))
            
            if let boards = workspace?.boards?.compactMap({ TaskDetailCellModel(id: "\($0.remoteId)", boardSelectorCellModel:
                                                                                    BoardSelectorCellModel(title: $0.title, iconResource: $0.assetUrl))}) {
                localSnapshot.append(contentsOf: boards)

                
            }
            
        }
        
        localSnapshot.append(TaskDetailCellModel(id: "1", priorityCellModel: PrioritySelectorCellModel(title: "High",
                                                                                                       description: "High priority task will go to top of your list and you will get notifications frequently",
                                                                                                       priority: .high, isHighlighted: true)))
        
        applySnapshot(items: localSnapshot)
        
        
    }
    
    @objc private func closeScreen(_ sender: UIButton) {
        coordinator?.dismissTaskCreationSheet()
    }
    
    @objc private func createNewTaskButtonDidTap(_ sender: UIButton) {
        let model = TaskBusinessModel(remoteId: -999,
                                      assigneeUserId: "im idin",
                                      title: "buhaah",
                                      detail: "d",
                                      dueDate: DateTimeUtils.convertDateToServerString(date: Date()),
                                      ownerBoardId: selectedBoard!.remoteId,
                                      status: "new",
                                      workspaceId: workspace!.remoteId,
                                      lastModifiedDate: DateTimeUtils.convertDateToServerString(date: Date()),
                                      isInitiallySynced: false,
                                      isPendingDeletionOnTheServer: false)
        
        boardViewModel.createNewTask(task: model)
    }
    



}

extension TaskDetailViewController {
    
    
    func applySnapshot(items: [TaskDetailCellModel], animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.generalInformationSection])
        snapshot.appendSections([.boardSelectorSection])
        snapshot.appendSections([.prioritySection])

        items.forEach { item in
            
            if item.generalInformationCellModel != nil {
                snapshot.appendItems([item], toSection: .generalInformationSection)
            }
            
            if item.boardSelectorCellModel != nil {
                snapshot.appendItems([item], toSection: .boardSelectorSection)
            }
            
            if item.priorityCellModel != nil {
                snapshot.appendItems([item], toSection: .prioritySection)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in
            guard let self = self else { return }
            
            if self.selectedBoard != nil && self.myColectionView.indexPathsForSelectedItems == [] {
                self.myColectionView.selectItem(at: IndexPath(item: 0, section: 1), animated: false, scrollPosition: [])
            }
        }
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, layoutEnvironment in

            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]

            switch section {
            case .generalInformationSection:
                return self.createGeneralInfoSectionLayout()
            case .boardSelectorSection:
                return self.createBoardSelectorSectionLayout()
            case .prioritySection:
                return self.createPrioritySelectorSectionLayout()
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
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(160))
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
    
    func createPrioritySelectorSectionLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(110))
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
    
    func generalInfoCellRegistration() -> UICollectionView.CellRegistration<TaskGeneralInfoCell, TaskDetailCellModel> {
        return .init { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            cell.model = itemIdentifier.generalInformationCellModel
            cell.delegate = self
        }
    }
    
    func prioritySelectorCellRegistration() -> UICollectionView.CellRegistration<PrioritySelectorCell, TaskDetailCellModel> {
        return .init { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            cell.model = itemIdentifier.priorityCellModel
            cell.delegate = self
        }
    }
    
    func boardSelectorCellRegistration() -> UICollectionView.CellRegistration<BoardSelectorCell, TaskDetailCellModel> {
        return .init { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            cell.model = itemIdentifier.boardSelectorCellModel
        }
    }
    
    func createDataSource() -> DataSource {
        let generalInfoCell = generalInfoCellRegistration()
        let manageAccessCell = boardSelectorCellRegistration()
        let priorityCell = prioritySelectorCellRegistration()

        let dataSource = DataSource(collectionView: myColectionView) { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier.section {
            case .generalInformationSection:
                return collectionView.dequeueConfiguredReusableCell(using: generalInfoCell, for: indexPath, item: itemIdentifier)
            case .boardSelectorSection:
                return collectionView.dequeueConfiguredReusableCell(using: manageAccessCell, for: indexPath, item: itemIdentifier)
            case .prioritySection:
                return collectionView.dequeueConfiguredReusableCell(using: priorityCell, for: indexPath, item: itemIdentifier)
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
            case .prioritySection:
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

extension TaskDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // TODO: We should crate enums for each section instead of using integers, Overall need to refactor
        // ordering logic for the collection view
        if indexPath.section != 1 { return false } else { return true }
        
    }
    
}

extension TaskDetailViewController: PrioritySelectionActionsProtocol {
    
    func actionDidHappen(action: PrioritySelectionAction) {
        
        if case .priorityShouldChange(let currentPriority) = action {
            boardViewModel.selectedPriority = currentPriority
            coordinator?.openPrioritySelectionSheet(withSelectedPriority: currentPriority)
        }
    }
    
    
}
