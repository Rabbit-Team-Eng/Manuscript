//
//  CreateNewBoardViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/4/22.
//

import UIKit
import CoreData
import Combine

enum BoardSheetState {
    case creation
    case edit
}

class BoardCreateEditViewController: UIViewController {
    
    weak var parentCoordinator: TabBarCoordinator? = nil
    
    private var tokens: Set<AnyCancellable> = []
    
    typealias DataSource = UICollectionViewDiffableDataSource<WorkspaceSelectorSectionType, IconSelectorCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<WorkspaceSelectorSectionType, IconSelectorCellModel>

    private lazy var dataSource = createDataSource()
    
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
    
    private let nameTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "accent_blue")
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontForContentSizeCategory = true
        label.text = "NAME"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let enterNameTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.setLeftPaddingPoints(16)
        textField.backgroundColor = Palette.gray
        textField.textColor = Palette.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let iconTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "accent_blue")
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontForContentSizeCategory = true
        label.text = "ICON"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // TODO: Check how to avoid lazy
    private lazy var myColectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: createCompositionalLayout())
        collectionView.backgroundColor = Palette.gray
        collectionView.allowsMultipleSelection = false
        collectionView.layer.cornerRadius = 16
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let createNewBoardeButton: UIButton = {
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
        button.setTitle("Delete Current Board", for: .normal)
        button.contentHorizontalAlignment = .center
        button.configuration?.baseBackgroundColor = Palette.blue
        button.setTitleColor(Palette.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(closeButton)
        view.addSubview(titleTexLabel)
        view.addSubview(nameTextLabel)
        view.addSubview(enterNameTextField)
        view.addSubview(iconTextLabel)
        view.addSubview(myColectionView)
        view.addSubview(createNewBoardeButton)

        view.backgroundColor = Palette.mediumDarkGray
        
        if case .creation = boardSheetState {
            titleTexLabel.text = "Create new board"
            createNewBoardeButton.configuration?.title = "Create New Board"
            createNewBoardeButton.addTarget(self, action: #selector(createNewBoardButtonDidTap(_:)), for: .touchUpInside)
            applySnapshot(items: IconProvider.icons(selectedIcon: nil))
        }
        
        if case .edit = boardSheetState {
            
            if let selectedBoard = mainViewModel.selectedBoard {
                titleTexLabel.text = "Edit Board"
                createNewBoardeButton.configuration?.title = "Save the changes"
                createNewBoardeButton.addTarget(self, action: #selector(editCurrentBoardButtonDidTap(_:)), for: .touchUpInside)
                deleteButton.addTarget(self, action: #selector(deletCurrentBoardButtonDidTap(_:)), for: .touchUpInside)
                enterNameTextField.text = selectedBoard.title
                view.addSubview(deleteButton)
                self.applySnapshot(items: IconProvider.icons(selectedIcon: selectedBoard.assetUrl))
            }
        }
        

        
        closeButton.addTarget(self, action: #selector(dismissScreen(_:)), for: .touchUpInside)
        
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, layoutEnvironment in
            return self.createIconsSection()
        }
        return layout
    }
    
    private func createIconsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/5),
                                              heightDimension: .fractionalWidth(1/5))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        return layoutSection
    }
    
    private func createDataSource() -> DataSource {
        let iconCell = iconCellRegistration()

        return DataSource(collectionView: myColectionView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: iconCell, for: indexPath, item: itemIdentifier)
        }
    }
    
    private func applySnapshot(items: [IconSelectorCellModel], animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in guard let self = self else { return }
            let firstItemIndexPathInCollectionView = IndexPath(item: 0, section: 0)
            self.myColectionView.selectItem(at: firstItemIndexPathInCollectionView, animated: false, scrollPosition: .top)
        }
    }
    
    private func iconCellRegistration() -> UICollectionView.CellRegistration<IconSelectorCell, IconSelectorCellModel> {
        return .init { cell, indexPath, itemIdentifier in
            cell.model = itemIdentifier
        }
    }
    
    @objc private func dismissScreen(_ sender: UIButton) {
        parentCoordinator?.dismissBoardCreationScreen()
    }
    
    @objc private func deletCurrentBoardButtonDidTap(_ sender: UIButton) {
        if let selectedBoard = mainViewModel.selectedBoard, let coreDataId = selectedBoard.coreDataId {
            mainViewModel.removeBoardForSelectedWorkspace(id: selectedBoard.remoteId, coreDataId: coreDataId)
        }
    }
    
    @objc private func createNewBoardButtonDidTap(_ sender: UIButton) {
        guard let title = enterNameTextField.text,
        let iconIndexPath = myColectionView.indexPathsForSelectedItems?.first,
        let icon = dataSource.itemIdentifier(for: iconIndexPath)?.iconResource else { return }
        mainViewModel.createBoardForSelectedWorkspace(title: title, asset: icon)
    }
    
    @objc private func editCurrentBoardButtonDidTap(_ sender: UIButton) {
        guard let title = enterNameTextField.text,
        let iconIndexPath = myColectionView.indexPathsForSelectedItems?.first,
        let icon = dataSource.itemIdentifier(for: iconIndexPath)?.iconResource else { return }

        if let selectedBoard = mainViewModel.selectedBoard, let coreDataId = selectedBoard.coreDataId {
            mainViewModel.editBoardForSelectedWorkspace(id: selectedBoard.remoteId, coreDataId: coreDataId, title: title, asset: icon)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate(getConstraintsForState(state: boardSheetState))
    }
    
    private let boardSheetState: BoardSheetState
    private let mainViewModel: BoardsViewModel
    
    init(boardSheetState: BoardSheetState, mainViewModel: BoardsViewModel) {
        self.boardSheetState = boardSheetState
        self.mainViewModel = mainViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {

    }
    
    private func getConstraintsForState(state: BoardSheetState) -> [NSLayoutConstraint] {
                
        switch state {
        case .creation:
            
            return [
                titleTexLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
                titleTexLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
                titleTexLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -32),
                titleTexLabel.heightAnchor.constraint(equalToConstant: 24),
                
                closeButton.centerYAnchor.constraint(equalTo: titleTexLabel.centerYAnchor),
                closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                closeButton.heightAnchor.constraint(equalToConstant: 24),
                closeButton.widthAnchor.constraint(equalToConstant: 24),
                
                nameTextLabel.topAnchor.constraint(equalTo: titleTexLabel.bottomAnchor, constant: 24),
                nameTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
                nameTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                nameTextLabel.heightAnchor.constraint(equalToConstant: 15),
                
                enterNameTextField.topAnchor.constraint(equalTo: nameTextLabel.bottomAnchor, constant: 8),
                enterNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                enterNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                enterNameTextField.heightAnchor.constraint(equalToConstant: 50),
                
                iconTextLabel.topAnchor.constraint(equalTo: enterNameTextField.bottomAnchor, constant: 16),
                iconTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
                iconTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                iconTextLabel.heightAnchor.constraint(equalToConstant: 24),
                
                myColectionView.topAnchor.constraint(equalTo: iconTextLabel.bottomAnchor, constant: 16),
                myColectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                myColectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                myColectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

                createNewBoardeButton.topAnchor.constraint(equalTo: myColectionView.bottomAnchor, constant: 32),
                createNewBoardeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
                createNewBoardeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                createNewBoardeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                createNewBoardeButton.heightAnchor.constraint(equalToConstant: 50),
            ]

        case .edit:
            
            return [
                titleTexLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
                titleTexLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
                titleTexLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -32),
                titleTexLabel.heightAnchor.constraint(equalToConstant: 24),
                
                closeButton.centerYAnchor.constraint(equalTo: titleTexLabel.centerYAnchor),
                closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                closeButton.heightAnchor.constraint(equalToConstant: 24),
                closeButton.widthAnchor.constraint(equalToConstant: 24),
                
                nameTextLabel.topAnchor.constraint(equalTo: titleTexLabel.bottomAnchor, constant: 24),
                nameTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
                nameTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                nameTextLabel.heightAnchor.constraint(equalToConstant: 15),
                
                enterNameTextField.topAnchor.constraint(equalTo: nameTextLabel.bottomAnchor, constant: 8),
                enterNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                enterNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                enterNameTextField.heightAnchor.constraint(equalToConstant: 50),
                
                iconTextLabel.topAnchor.constraint(equalTo: enterNameTextField.bottomAnchor, constant: 16),
                iconTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
                iconTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                iconTextLabel.heightAnchor.constraint(equalToConstant: 24),
                
                myColectionView.topAnchor.constraint(equalTo: iconTextLabel.bottomAnchor, constant: 16),
                myColectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                myColectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                myColectionView.bottomAnchor.constraint(equalTo: createNewBoardeButton.topAnchor, constant: -32),
                
                createNewBoardeButton.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -32),
                createNewBoardeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                createNewBoardeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                createNewBoardeButton.heightAnchor.constraint(equalToConstant: 50),
                
                deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
                deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                deleteButton.heightAnchor.constraint(equalToConstant: 50),
                
            ]
        }
    }

}
