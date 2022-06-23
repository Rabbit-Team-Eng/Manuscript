//
//  BoardDetailViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/8/22.
//

import UIKit
import Combine

class BoardDetailViewController: UIViewController {
    
    weak var coordinator: BoardsCoordinator? = nil
    
    typealias DataSource = UICollectionViewDiffableDataSource<TaskSectionType, TaskCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<TaskSectionType, TaskCellModel>
    
    
    lazy var myColectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = Palette.lightBlack
        return collectionView
    }()
    
    lazy var dataSource = createDataSource()

    private var selectedWorkspace: WorkspaceBusinessModel
    private var selectedBoard: BoardBusinessModel
    private let boardViewModel: BoardsViewModel
    private var tokens: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.lightBlack
        
        view.addSubview(myColectionView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward.square"), style: .plain, target: self, action: #selector(backButtonDidTap(_:)))
 
        myColectionView.register(TaskGeneralInfoSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TaskGeneralInfoSectionHeaderView.reuseIdentifier)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewTaskButtonDidTap(_:))),
            UIBarButtonItem(image: UIImage(systemName: "slider.vertical.3"), style: .plain, target: self, action: #selector(editCurrentBoardButtonDidTap(_:))),
        ]
        
        
        self.navigationItem.title = selectedBoard.title
        
        boardViewModel.events.sink { completion in } receiveValue: { [weak self] event in guard let self = self else { return }
            
            if case .boardsDidFetch(let boards) = event {
                print(boards.first { $0.remoteId == self.selectedBoard.remoteId } ?? "We need to handle this error when deleting board!")
            }
            
            if case .currentBoardDidEdit(let board) = event {
                self.selectedBoard = board
                self.navigationItem.title = board.title
                self.coordinator?.dismissBoardCreationScreen()
            }
            
            if case .taskJustCreatedLocally(let board) = event {
                if let tasks = board.tasks {
                    self.applySnapshot(items: TaskTransformer.transformTasksToTaskCellModel(tasks: tasks))
                    self.coordinator?.dismissTaskCreationScreen()
                }
  
            }
            
            if case .taskJustEditedLocally(let board) = event {
                if let tasks = board.tasks {
                    self.selectedBoard = board
                    self.navigationItem.title = board.title
                    self.applySnapshot(items: TaskTransformer.transformTasksToTaskCellModel(tasks: tasks))
                    self.coordinator?.dismissTaskCreationScreen()
                }
            }
        }
        .store(in: &tokens)
        
        if let tasks = selectedBoard.tasks {
            
            let taskCellModels = tasks.map { TaskCellModel(id: "\($0.remoteId)",
                                                           title: $0.title,
                                                           description: $0.detail ?? "",
                                                           priority: $0.priority,
                                                           assignee: $0.assigneeUserId,
                                                           status: $0.status,
                                                           boardTitle: selectedBoard.title)}
            
            
            applySnapshot(items: taskCellModels)
        }
        

        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate([
        
            myColectionView.topAnchor.constraint(equalTo: view.topAnchor),
            myColectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            myColectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            myColectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc private func backButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.goBackFromWorkspaceCreationScreen()
    }
    
    
    @objc private func createNewTaskButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.presentCreateEditTaskSheet(taskDetailState: .creation, workspaceBusinessModel: selectedWorkspace, selectedBoard: selectedBoard, selectedTask: nil)
    }
    
    @objc private func editCurrentBoardButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.presentCreateBoardScreen(state: .edit(id: selectedBoard.remoteId))
    }
    
    init(selectedWorkspace: WorkspaceBusinessModel, selectedBoard: BoardBusinessModel, boardViewModel: BoardsViewModel) {
        self.selectedWorkspace = selectedWorkspace
        self.selectedBoard = selectedBoard
        self.boardViewModel = boardViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {

    }

}

extension BoardDetailViewController {
    
    
    func applySnapshot(items: [TaskCellModel], animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        
        let priorities = items.compactMap({ $0.priority })
        
        if priorities.contains(Priority.high) {
            snapshot.appendSections([.highPrioritySection])
        }
        
        if priorities.contains(Priority.medium) {
            snapshot.appendSections([.mediumPrioritySection])
        }
        
        if priorities.contains(Priority.low) {
            snapshot.appendSections([.lowPrioritySection])
        }

        items.forEach { item in
            
            if item.priority == .high {
                snapshot.appendItems([item], toSection: .highPrioritySection)
            }
            
            if item.priority == .medium {
                snapshot.appendItems([item], toSection: .mediumPrioritySection)
            }
            
            if item.priority == .low {
                snapshot.appendItems([item], toSection: .lowPrioritySection)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, layoutEnvironment in

            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]

            switch section {
            case .highPrioritySection:
                return self.createPrioritySelectorSectionLayout()
            case .mediumPrioritySection:
                return self.createPrioritySelectorSectionLayout()
            case .lowPrioritySection:
                return self.createPrioritySelectorSectionLayout()
            default:
                fatalError()
            }
        }

        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()
        return layout
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
    
    func taskCellRegistration() -> UICollectionView.CellRegistration<TaskCell, TaskCellModel> {
        return .init { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            cell.model = itemIdentifier
            cell.delegate = self
        }
    }

    
    func createDataSource() -> DataSource {
        let generalInfoCell = taskCellRegistration()


        let dataSource = DataSource(collectionView: myColectionView) { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier.priority {
            case .high:
                return collectionView.dequeueConfiguredReusableCell(using: generalInfoCell, for: indexPath, item: itemIdentifier)
            case .medium:
                return collectionView.dequeueConfiguredReusableCell(using: generalInfoCell, for: indexPath, item: itemIdentifier)
            case .low:
                return collectionView.dequeueConfiguredReusableCell(using: generalInfoCell, for: indexPath, item: itemIdentifier)
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .highPrioritySection:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskGeneralInfoSectionHeaderView.reuseIdentifier, for: indexPath) as? TaskGeneralInfoSectionHeaderView
                view?.titleLabel.text = section.sectionHeaderTitle
                return view
            case .mediumPrioritySection:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskGeneralInfoSectionHeaderView.reuseIdentifier, for: indexPath) as? TaskGeneralInfoSectionHeaderView
                view?.titleLabel.text = section.sectionHeaderTitle
                return view
            case .lowPrioritySection:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskGeneralInfoSectionHeaderView.reuseIdentifier, for: indexPath) as? TaskGeneralInfoSectionHeaderView
                view?.titleLabel.text = section.sectionHeaderTitle
                return view

            }
        }
        return dataSource
    }
}

extension BoardDetailViewController: TaskCellProtocol {
    
    func taskDidSelected(task: TaskCellModel) {
        if let tasks = selectedBoard.tasks, let selectedTask = tasks.first(where: { "\($0.remoteId)" == task.id }) {
            coordinator?.presentCreateEditTaskSheet(taskDetailState: .edit, workspaceBusinessModel: selectedWorkspace, selectedBoard: selectedBoard, selectedTask: selectedTask)
        }
    }
        
}
