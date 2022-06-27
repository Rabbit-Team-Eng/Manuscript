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

    private var tokens: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.lightBlack
        
        view.addSubview(myColectionView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward.square"), style: .plain, target: self, action: #selector(backButtonDidTap(_:)))
 
        myColectionView.register(TaskGeneralInfoSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TaskGeneralInfoSectionHeaderView.reuseIdentifier)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: Icon.plus, style: .plain, target: self, action: #selector(createNewTaskButtonDidTap(_:))),
            UIBarButtonItem(image: Icon.edit, style: .plain, target: self, action: #selector(editCurrentBoardButtonDidTap(_:))),
        ]
        
        refreshBoardDate()
        
        mainViewModel.boardsViewControllerUIEvent
            .receive(on: RunLoop.main)
            .sink { [weak self] event in guard let self = self else { return }
                
                if case .existingBoardDidUpdated = event {
                    
                    self.coordinator?.dismissBoardCreationScreen()
                    self.refreshBoardDate()
                }
                
                if case .newTaskDidCreated = event {
                    self.coordinator?.dismissTaskCreationScreen()
                    self.refreshBoardDate()
                }

            }
            .store(in: &tokens)
        
        mainViewModel.selectedWorkspacePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] workspaceBusinessModel in guard let self = self else { return }
                self.refreshBoardDate()
            }
            .store(in: &tokens)

    }
    
    private func refreshBoardDate() {
        if let board = mainViewModel.selectedBoard {
            self.navigationItem.title = board.title
            
            if let tasks = board.tasks?.sorted() {

                let taskCellModels = tasks.map { TaskCellModel(id: "\($0.remoteId)",
                                                               title: $0.title,
                                                               description: $0.detail ?? "",
                                                               priority: $0.priority,
                                                               assignee: $0.assigneeUserId,
                                                               status: $0.status,
                                                               boardTitle: board.title)}


                applySnapshot(items: taskCellModels, animatingDifferences: true)
            }
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
        coordinator?.presentCreateEditTaskSheet(taskDetailState: .creation)
    }
    
    @objc private func editCurrentBoardButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.presentBoardCreateEditScreen(state: .edit)
    }
    
    private let mainViewModel: BoardsViewModel

    init(mainViewModel: BoardsViewModel) {
        self.mainViewModel = mainViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {

    }

}

extension BoardDetailViewController {
    
    
    func applySnapshot(items: [TaskCellModel], animatingDifferences: Bool) {
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
//        if let tasks = selectedBoard.tasks, let selectedTask = tasks.first(where: { "\($0.remoteId)" == task.id }) {
//            coordinator?.presentCreateEditTaskSheet(taskDetailState: .edit, workspaceBusinessModel: selectedWorkspace, selectedBoard: selectedBoard, selectedTask: selectedTask)
//        }
    }
        
}
