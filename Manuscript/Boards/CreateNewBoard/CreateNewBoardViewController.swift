//
//  CreateNewBoardViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/4/22.
//

import UIKit

class CreateNewBoardViewController: UIViewController {
    
    weak var parentCoordinator: TabBarCoordinator? = nil
    
    typealias DataSource = UICollectionViewDiffableDataSource<WorkspaceSelectorSectionType, IconCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<WorkspaceSelectorSectionType, IconCellModel>

    private lazy var dataSource = createDataSource()
    
    private let titleTexLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.preferredFont(for: .title2, weight: .bold)
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.text = "Create new board"
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
        button.configuration?.title = "Create New Board"
        button.contentHorizontalAlignment = .center
        button.configuration?.baseBackgroundColor = Palette.blue
        button.setTitleColor(Palette.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        view.addSubview(titleTexLabel)
        view.addSubview(nameTextLabel)
        view.addSubview(enterNameTextField)
        view.addSubview(iconTextLabel)
        view.addSubview(myColectionView)
        view.addSubview(createNewBoardeButton)

        view.backgroundColor = Palette.mediumDarkGray
        
        applySnapshot(items: [
        
            IconCellModel(id: "square.and.arrow.up.on.square", iconResource: "square.and.arrow.up.on.square"),
            IconCellModel(id: "pencil.circle.fill", iconResource: "pencil.circle.fill"),
            IconCellModel(id: "pencil.tip", iconResource: "pencil.tip"),
            IconCellModel(id: "lasso", iconResource: "lasso"),
            IconCellModel(id: "trash", iconResource: "trash"),
            IconCellModel(id: "folder", iconResource: "folder"),
            IconCellModel(id: "paperplane.circle", iconResource: "paperplane.circle"),
            IconCellModel(id: "externaldrive.badge.minus", iconResource: "externaldrive.badge.minus"),
            IconCellModel(id: "doc.on.clipboard.fill", iconResource: "doc.on.clipboard.fill"),
            IconCellModel(id: "doc.text.below.ecg", iconResource: "doc.text.below.ecg"),
            IconCellModel(id: "text.book.closed", iconResource: "text.book.closed"),
            IconCellModel(id: "greetingcard", iconResource: "greetingcard"),
            IconCellModel(id: "person", iconResource: "person"),
            IconCellModel(id: "command.square.fill", iconResource: "command.square.fill"),
            IconCellModel(id: "globe", iconResource: "globe"),
            
            IconCellModel(id: "calendar.day.timeline.trailing", iconResource: "calendar.day.timeline.trailing"),
            IconCellModel(id: "arrowshape.bounce.right", iconResource: "arrowshape.bounce.right"),
            IconCellModel(id: "book.closed", iconResource: "book.closed"),
            IconCellModel(id: "newspaper.circle", iconResource: "newspaper.circle"),
            IconCellModel(id: "rosette", iconResource: "rosette"),
            IconCellModel(id: "graduationcap.fill", iconResource: "graduationcap.fill"),
            IconCellModel(id: "paperclip.badge.ellipsis", iconResource: "paperclip.badge.ellipsis"),
            IconCellModel(id: "personalhotspot", iconResource: "personalhotspot"),
            IconCellModel(id: "rectangle.inset.filled.and.person.filled", iconResource: "rectangle.inset.filled.and.person.filled"),
            IconCellModel(id: "person.fill.and.arrow.left.and.arrow.right", iconResource: "person.fill.and.arrow.left.and.arrow.right"),
            IconCellModel(id: "sun.max.fill", iconResource: "sun.max.fill"),
            IconCellModel(id: "moon.zzz", iconResource: "moon.zzz"),
            IconCellModel(id: "cloud.sleet.fill", iconResource: "cloud.sleet.fill"),
            IconCellModel(id: "smoke", iconResource: "smoke"),
            IconCellModel(id: "umbrella.fill", iconResource: "umbrella.fill"),
            IconCellModel(id: "cursorarrow.and.square.on.square.dashed", iconResource: "cursorarrow.and.square.on.square.dashed"),
            IconCellModel(id: "rectangle.grid.2x2", iconResource: "rectangle.grid.2x2"),
            IconCellModel(id: "circle.grid.3x3", iconResource: "circle.grid.3x3"),
            IconCellModel(id: "circle.hexagongrid", iconResource: "circle.hexagongrid"),
            IconCellModel(id: "seal.fill", iconResource: "seal.fill"),
            IconCellModel(id: "exclamationmark.triangle", iconResource: "exclamationmark.triangle"),
            IconCellModel(id: "play.fill", iconResource: "play.fill"),
            IconCellModel(id: "memories.badge.plus", iconResource: "memories.badge.plus"),
            IconCellModel(id: "infinity.circle", iconResource: "infinity.circle"),
            IconCellModel(id: "speaker.zzz.fill", iconResource: "speaker.zzz.fill"),


        ])
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            return self.createIconsSection()
        }
        return layout
    }
    
    private func createIconsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/5),
                                              heightDimension: .fractionalHeight(1))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/5))
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
    
    private func applySnapshot(items: [IconCellModel], animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in guard let self = self else { return }
            let firstItemIndexPathInCollectionView = IndexPath(item: 0, section: 0)
            self.myColectionView.selectItem(at: firstItemIndexPathInCollectionView, animated: false, scrollPosition: .top)
        }
    }
    
    private func iconCellRegistration() -> UICollectionView.CellRegistration<IconCell, IconCellModel> {
        return .init { cell, indexPath, itemIdentifier in
            cell.model = itemIdentifier
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate([
            titleTexLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            titleTexLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
            titleTexLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            titleTexLabel.heightAnchor.constraint(equalToConstant: 24),
            
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
            
            createNewBoardeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            createNewBoardeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            createNewBoardeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            createNewBoardeButton.heightAnchor.constraint(equalToConstant: 50),

        ])
    }

}
