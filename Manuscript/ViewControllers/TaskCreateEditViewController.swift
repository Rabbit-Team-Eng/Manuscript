//
//  TaskCreateViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/8/22.
//

import UIKit
import Combine

enum TaskSheetState {
    case creation
    case edit
}

class TaskCreateEditViewController: UIViewController {
    
    weak var coordinator: TabBarCoordinator? = nil
    
    typealias DataSource = UICollectionViewDiffableDataSource<TaskDetailSectionType, TaskDetailCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<TaskDetailSectionType, TaskDetailCellModel>
    
    lazy var dataSource = createDataSource()
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
      
    private let createNewTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
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

    private let state: TaskSheetState
    private let viewModel: BoardsViewModel
    private let taskFlowInteractor: TaskFlowInteractor
    
    init(state: TaskSheetState, viewModel: BoardsViewModel, taskFlowInteractor: TaskFlowInteractor) {
        self.state = state
        self.viewModel = viewModel
        self.taskFlowInteractor = taskFlowInteractor
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
        
        
        if state == .creation {
            createNewTaskButton.configuration?.title = "Create New Task"
            titleTexLabel.text = "Create new Task"
            createNewTaskButton.addTarget(self, action: #selector(createNewTaskButtonDidTap(_:)), for: .touchUpInside)
            NSLayoutConstraint.activate(creationConstraints)
            taskFlowInteractor.selectNewPriority(priority: .high)
            
            if let id = viewModel.selectedBoard?.remoteId { taskFlowInteractor.selectNewBoard(id: id) }
        }
        
        if state == .edit {
            createNewTaskButton.configuration?.title = "Edit current Task"
            titleTexLabel.text = "Edit current Task"
            createNewTaskButton.addTarget(self, action: #selector(editCurrentTaskButtonDidTap(_:)), for: .touchUpInside)
            deleteButton.addTarget(self, action: #selector(deleteCurrentTaskButtonDidTap(_:)), for: .touchUpInside)

            if let task = viewModel.selectedTask {
                taskFlowInteractor.selectNewPriority(priority: task.priority)
            }
            view.addSubview(deleteButton)
            NSLayoutConstraint.activate(editConstraints)

        }
        
        refreshData(for: state)
        
        taskFlowInteractor.taskFlowUIEvent
            .receive(on: RunLoop.main)
            .sink { [weak self] event in guard let self = self else { return }
                if let board = self.viewModel.selectedBoard, let allBoards = self.viewModel.selectedSpace?.boards, let priority = self.taskFlowInteractor.selectedPriority {
                    let localSnapshot = TaksSectionProvider.provideSectionsForCreateState(board: board, allBoards: allBoards, priorirty: priority)
                    self.applySnapshot(snapshot: localSnapshot)
                }
                self.coordinator?.dismissPrioritySheet()
            }
            .store(in: &tokens)
        
        viewModel.selectedWorkspacePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] workspaceBusinessModel in guard let self = self else { return }
                self.refreshData(for: self.state)
            }
            .store(in: &tokens)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func dismissKeyboard(_ sender: UIView) {
        view.endEditing(true)
    }
    
    func refreshData(for state: TaskSheetState) {
        
        if state == .edit {
            if let board = viewModel.selectedBoard,
               let allBoards = viewModel.selectedSpace?.boards,
               let priority = taskFlowInteractor.selectedPriority,
               let task = viewModel.selectedTask {
                
                let localSnapshot = TaksSectionProvider.provideEditState(task: task, board: board, allBoards: allBoards, priorirty: priority)
                applySnapshot(snapshot: localSnapshot, animatingDifferences: true)
            }
        }
        
        if state == .creation {
            if let board = viewModel.selectedBoard, let allBoards = viewModel.selectedSpace?.boards, let priority = taskFlowInteractor.selectedPriority {
                let localSnapshot = TaksSectionProvider.provideSectionsForCreateState(board: board, allBoards: allBoards, priorirty: priority)
                applySnapshot(snapshot: localSnapshot, animatingDifferences: true)
            }
        }
        

    }
    
    @objc private func closeScreen(_ sender: UIButton) {
        coordinator?.dismissTaskCreationSheet()
    }
    
    @objc private func createNewTaskButtonDidTap(_ sender: UIButton) {
        
        if let selectedPriority = taskFlowInteractor.selectedPriority,
           let title = taskFlowInteractor.newTitle,
           let description = taskFlowInteractor.newDescription,
           let selectedBoard = taskFlowInteractor.selectedBoardId
        {
            viewModel.createTaskForBoard(title: title,
                                         description: description,
                                         doeDate: DateTimeUtils.convertDateToServerString(date: .now + 2),
                                         ownerBoardId: selectedBoard,
                                         status: "Open",
                                         priority: PriorityTypeConverter.getString(priority: selectedPriority),
                                         assigneeUserId: "")


        }
     
    }
    
    @objc private func deleteCurrentTaskButtonDidTap(_ sender: UIButton) {
        if let selectedTask = viewModel.selectedTask, let coreDataId = selectedTask.coreDataId {
            viewModel.removeTaskForBoard(id: selectedTask.remoteId , coreDataId: coreDataId, isInitiallySynced: selectedTask.isInitiallySynced)
        }
    }
    
    @objc private func editCurrentTaskButtonDidTap(_ sender: UIButton) {
        
        if let selectedPriority = taskFlowInteractor.selectedPriority,
           let title = taskFlowInteractor.newTitle,
           let description = taskFlowInteractor.newDescription,
           let selectedBoard = taskFlowInteractor.selectedBoardId,
           let selectedTask = viewModel.selectedTask,
           let coreDataId = selectedTask.coreDataId
        {
            viewModel.editTaskForBoard(id: selectedTask.remoteId,
                                       coreDataId: coreDataId,
                                       title: title,
                                       description: description,
                                       doeDate: selectedTask.dueDate,
                                       ownerBoardId: selectedBoard,
                                       status: selectedTask.status,
                                       priority: PriorityTypeConverter.getString(priority: selectedPriority),
                                       assigneeUserId: selectedTask.assigneeUserId,
                                       isInitiallySynced: selectedTask.isInitiallySynced,
                                       isPendingDeletionOnTheServer: selectedTask.isPendingDeletionOnTheServer)


        }

    }



}

extension TaskCreateEditViewController {
    
    
    func applySnapshot(snapshot: Snapshot, animatingDifferences: Bool = false) {
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in
            guard let self = self else { return }
            
            if self.viewModel.selectedBoard != nil && self.myColectionView.indexPathsForSelectedItems == [] {
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

            }
        }
        return dataSource
    }
}

extension TaskCreateEditViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        selectedBoardId = dataSource.itemIdentifier(for: indexPath)?.id
        if indexPath.section != 1 { return false } else { return true }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let item = dataSource.itemIdentifier(for: indexPath)?.id {
            taskFlowInteractor.selectNewBoard(id: Int64(item)!)

        }
    }
    
}

extension TaskCreateEditViewController: PrioritySelectionActionsProtocol, TaskDetailActionProtocol {
    
    func actionDidHappen(action: TaskDetailAction) {
        switch action {
        case .descriptionDidUpdated(let text):
            taskFlowInteractor.setDescription(description: text)
        case .titleDidUpdated(let text):
            taskFlowInteractor.setTitle(title: text)
        }
    }
    
    
    func actionDidHappen(action: PrioritySelectionAction) {
        
        if case .priorityShouldChange(let currentPriority) = action {
            coordinator?.openPrioritySelectionSheet(withSelectedPriority: currentPriority)
        }
    }
}


enum TaskFlowUIEvent {
    case newPriorityDidSet
}

class TaskFlowInteractor {
    
    private(set) var selectedPriority: Priority?
    private(set) var selectedBoardId: Int64?
    private(set) var newTitle: String?
    private(set) var newDescription: String?

    var taskFlowUIEvent: PassthroughSubject<TaskFlowUIEvent, Never> = PassthroughSubject()
    
    func selectNewPriority(priority: Priority) {
        selectedPriority = priority
        taskFlowUIEvent.send(.newPriorityDidSet)
    }
    
    func selectNewBoard(id: Int64) {
        selectedBoardId = id
    }
    
    func setTitle(title: String) {
        newTitle = title
    }
    
    func setDescription(description: String) {
        newDescription = description
    }
    
}


public struct TaksSectionProvider {
    
    static func provideEditState(task: TaskBusinessModel, board: BoardBusinessModel, allBoards: [BoardBusinessModel], priorirty: Priority) -> NSDiffableDataSourceSnapshot<TaskDetailSectionType, TaskDetailCellModel> {
        var snapshot = NSDiffableDataSourceSnapshot<TaskDetailSectionType, TaskDetailCellModel>()
        
        var localSnapshot: [TaskDetailCellModel] = []

        localSnapshot.append(TaskDetailCellModel(id: "0",  generalInformationCellModel: TaskGeneralInfoCellModel(title: task.title, description: task.detail ?? "", isEditable: true, needPlaceholders: true)))
        
        localSnapshot.append(TaskDetailCellModel(id: "\(board.remoteId)", boardSelectorCellModel: BoardSelectorCellModel(title: board.title, iconResource: board.assetUrl)))
        
        let otherBoardAfterFilter = allBoards.filter { $0.remoteId != board.remoteId }.map {
            TaskDetailCellModel(id: "\($0.remoteId)", boardSelectorCellModel: BoardSelectorCellModel(title: $0.title, iconResource: $0.assetUrl))
        }
        
        
        localSnapshot.append(contentsOf: otherBoardAfterFilter)
        
        let priorityCell = TaksSectionProvider.providePrioritySection(id: "1", priority: priorirty, isHighlighted: true)
        
        localSnapshot.append(priorityCell)
        
        
        snapshot.appendSections([.generalInformationSection])
        snapshot.appendSections([.boardSelectorSection])
        snapshot.appendSections([.prioritySection])

        localSnapshot.forEach { item in
            
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
        
        return snapshot
    }
    
    static func provideSectionsForCreateState(board: BoardBusinessModel, allBoards: [BoardBusinessModel], priorirty: Priority) -> NSDiffableDataSourceSnapshot<TaskDetailSectionType, TaskDetailCellModel> {
        var snapshot = NSDiffableDataSourceSnapshot<TaskDetailSectionType, TaskDetailCellModel>()
        
        var localSnapshot: [TaskDetailCellModel] = []

        localSnapshot.append(TaskDetailCellModel(id: "0",  generalInformationCellModel: TaskGeneralInfoCellModel(title: "", description: "", isEditable: true, needPlaceholders: true)))
        
        localSnapshot.append(TaskDetailCellModel(id: "\(board.remoteId)", boardSelectorCellModel: BoardSelectorCellModel(title: board.title, iconResource: board.assetUrl)))
        
        let otherBoardAfterFilter = allBoards.filter { $0.remoteId != board.remoteId }.map {
            TaskDetailCellModel(id: "\($0.remoteId)", boardSelectorCellModel: BoardSelectorCellModel(title: $0.title, iconResource: $0.assetUrl))
        }
        
        
        localSnapshot.append(contentsOf: otherBoardAfterFilter)
        
        let priorityCell = TaksSectionProvider.providePrioritySection(id: "1", priority: priorirty, isHighlighted: true)
        
        localSnapshot.append(priorityCell)
        
        
        snapshot.appendSections([.generalInformationSection])
        snapshot.appendSections([.boardSelectorSection])
        snapshot.appendSections([.prioritySection])

        localSnapshot.forEach { item in
            
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
        
        return snapshot
    }
    
    static func providePrioritySection(id: String, priority: Priority, isHighlighted: Bool) -> TaskDetailCellModel {
        
        switch priority {
        case .low:
            return TaskDetailCellModel(id: id,
                                       priorityCellModel: PrioritySelectorCellModel(title: "Low",
                                                                                    description: "Low priority task which will go to the end of your task list",
                                                                                    priority: .low,
                                                                                    isHighlighted: isHighlighted))
        case .medium:
            return TaskDetailCellModel(id: id,
                                       priorityCellModel: PrioritySelectorCellModel(title: "Medium",
                                                                                    description: "Medium priority is a regular task which will be in your task list",
                                                                                    priority: .medium,
                                                                                    isHighlighted: isHighlighted))
        case .high:
            return TaskDetailCellModel(id: id,
                                       priorityCellModel: PrioritySelectorCellModel(title: "High",
                                                                                    description: "High priority task will go to top of your list and you will get notifications frequently",
                                                                                    priority: .high,
                                                                                    isHighlighted: isHighlighted))
        }
    }
}
