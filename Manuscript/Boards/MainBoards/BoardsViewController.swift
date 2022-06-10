//
//  BoardsViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit
import Combine
import Lottie

struct BoardCellModel: Hashable {
    let remoteId: String
    let boardTitle: String
    let numberOfTasks: Int
    let imageIcon: String
    let isSynced: Bool
    
    init(remoteId: String, boardTitle: String, numberOfTasks: Int, imageIcon: String, isSynced: Bool) {
        self.remoteId = remoteId
        self.boardTitle = boardTitle
        self.numberOfTasks = numberOfTasks
        self.imageIcon = imageIcon
        self.isSynced = isSynced
    }
}


class BoardsViewController: UIViewController, UICollectionViewDelegate {

    weak var coordinator: BoardsCoordinator? = nil
    
    enum BoardViewControllerSection {
        case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<BoardViewControllerSection, BoardCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<BoardViewControllerSection, BoardCellModel>
    
    // TODO: Check how to avoid lazy
    private lazy var myColectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.backgroundColor = Palette.lightBlack
        return collectionView
    }()
    
    private lazy var dataSource = createDataSource()
    
    private let titleTexLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.preferredFont(for: .headline, weight: .medium)
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.text = "You have no boards in this space. Let’s create one!"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lottieAnimationView: AnimationView = {
        var animation = AnimationView(animation: Animation.named("107448-human-in-vr-glasses-in-metaverse"))
        animation.loopMode = .loop
        animation.translatesAutoresizingMaskIntoConstraints = false
        return animation
    }()
    
    private let createBoardButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.title = "Create New Board"
        button.contentHorizontalAlignment = .center
        button.configuration?.baseBackgroundColor = Palette.blue
        button.setTitleColor(Palette.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    private let boardsViewModel: BoardsViewModel
    private let startUpUtils: StartupUtils
    private let databaseManager: DatabaseManager
    private var tokens: Set<AnyCancellable> = []

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Palette.lightBlack
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(signOut(_:)))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewBoard(_:))),
            UIBarButtonItem(image: UIImage(systemName: "square.stack.3d.up"), style: .plain, target: self, action: #selector(openWorkspaceSelector(_:))),
            UIBarButtonItem(image: UIImage(systemName: "cloud"), style: .plain, target: self, action: #selector(cloudSyncButtonDidTap(_:)))
        ]
        createBoardButton.addTarget(self, action: #selector(createBoardButtonDidTap(_:)), for: .touchUpInside)
        myColectionView.delegate = self
        
        boardsViewModel.events
            .receive(on: RunLoop.main)
            .sink { completion in } receiveValue: { [weak self] event in guard let self = self else { return }
                
                if case .titleDidFetch(let title) = event {
                    self.navigationItem.title = title
                }
                
                if case .noBoardIsCreated = event {
                    self.determineBoardPlaceholder(hasBoards: false)
                }
                
                if case .boardsDidFetch(let boards) = event {
                    self.determineBoardPlaceholder(hasBoards: true, boards: boards)
                }
                
                if case .newBoardDidCreated = event {
                    self.coordinator?.dismissBoardCreationScreen()
                }
        }
        .store(in: &tokens)

    }
    
    @objc private func cloudSyncButtonDidTap(_ sender: UIBarButtonItem) {
        print("---------------Clicked---------------")
        boardsViewModel.syncTheCloud()
    }
    
    @objc private func openWorkspaceSelector(_ sender: UIBarButtonItem) {
        coordinator?.presentWorkspaceSelectorScreen()
    }
    
    @objc private func createNewBoard(_ sender: UIBarButtonItem) {
        coordinator?.presentCreateBoardScreen()
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            return self.createBoardsSection()
        }
        return layout
    }
    
    private func createBoardsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        return layoutSection
    }
    
    private func createDataSource() -> DataSource {
        let boardCell = boardCellRegistration()

        return DataSource(collectionView: myColectionView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: boardCell, for: indexPath, item: itemIdentifier)
        }
    }
    
    private func applySnapshot(items: [BoardCellModel], animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func boardCellRegistration() -> UICollectionView.CellRegistration<BoardCollectionViewCell, BoardCellModel> {
        return .init { cell, indexPath, itemIdentifier in
            cell.configure(cellModel: itemIdentifier)
        }
    }

    private func determineBoardPlaceholder(hasBoards: Bool, boards: [BoardBusinessModel]? = nil) {
        if hasBoards {
            if titleTexLabel.isDescendant(of: view) {
                titleTexLabel.removeFromSuperview()
            }
            if lottieAnimationView.isDescendant(of: view) {
                lottieAnimationView.removeFromSuperview()
            }
            if createBoardButton.isDescendant(of: view) {
                createBoardButton.removeFromSuperview()
            }
            view.addSubview(myColectionView)
            applySnapshot(items: BoardTransformer.transformBoardsToCellModel(boards: boards!), animatingDifferences: true)
        } else {
            myColectionView.removeFromSuperview()
            view.addSubview(titleTexLabel)
            view.addSubview(lottieAnimationView)
            view.addSubview(createBoardButton)
            
            NSLayoutConstraint.activate([
                titleTexLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                titleTexLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                titleTexLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -62),
                titleTexLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 62),
                titleTexLabel.heightAnchor.constraint(equalToConstant: 48),
                
                lottieAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                lottieAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -62),
                lottieAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 62),
                lottieAnimationView.heightAnchor.constraint(equalToConstant: 170),
                lottieAnimationView.bottomAnchor.constraint(equalTo: titleTexLabel.topAnchor, constant: -32),
                
                createBoardButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                createBoardButton.heightAnchor.constraint(equalToConstant: 50),
                createBoardButton.widthAnchor.constraint(equalToConstant: 195),
                createBoardButton.topAnchor.constraint(equalTo: titleTexLabel.bottomAnchor, constant: 50)

            ])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        boardsViewModel.fetchCurrentWorkspace()
        if lottieAnimationView.isDescendant(of: view) {
            lottieAnimationView.play()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        

    }
    
    @objc private func createBoardButtonDidTap(_ sender: UIButton) {
        coordinator?.presentCreateBoardScreen()
    }
    
    @objc private func signOut(_ sender: UIBarButtonItem) {
        UserDefaults.selectedWorkspaceId = ""
        startUpUtils.deleteAcessToken()
        databaseManager.clearDatabase()
        coordinator?.signeOut()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedBoardId = dataSource.itemIdentifier(for: indexPath)?.remoteId else { return }
        coordinator?.navigateToBoardDetail(withId: selectedBoardId)
    }

    init(boardsViewModel: BoardsViewModel, startUpUtils: StartupUtils, databaseManager: DatabaseManager) {
        self.boardsViewModel = boardsViewModel
        self.startUpUtils = startUpUtils
        self.databaseManager = databaseManager
        print("AVERAKEDABRA: ALLOC -> BoardsViewController")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    deinit {
        print("AVERAKEDABRA: RELEASE -> BoardsViewController")
    }
}

class BoardCollectionViewCell: UICollectionViewCell {
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(hex: "#3A71F6")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var syncIndicatorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var numberOfTasksLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .white.withAlphaComponent(0.5)
        label.font = UIFont.systemFont(ofSize: 14)
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInitilization()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitilization()
    }
    
    func configure(cellModel: BoardCellModel) {
        numberOfTasksLabel.text = "\(cellModel.numberOfTasks) Tasks"
        titleLabel.text = cellModel.boardTitle
        iconImageView.image = UIImage(systemName: cellModel.imageIcon)
        
        if cellModel.isSynced {
            syncIndicatorImageView.tintColor = Palette.mediumDarkGray
        } else {
            syncIndicatorImageView.tintColor = Palette.magenta
        }
    }
    
    func commonInitilization() {
        layer.cornerRadius = 22
        backgroundColor = Palette.mediumDarkGray
        contentView.addSubview(titleLabel)
        contentView.addSubview(numberOfTasksLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(syncIndicatorImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            numberOfTasksLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            numberOfTasksLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            numberOfTasksLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            numberOfTasksLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 25),
            
            titleLabel.bottomAnchor.constraint(equalTo: numberOfTasksLabel.topAnchor, constant: -8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            numberOfTasksLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            
            syncIndicatorImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            syncIndicatorImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            syncIndicatorImageView.heightAnchor.constraint(equalToConstant: 10),
            syncIndicatorImageView.widthAnchor.constraint(equalToConstant: 10),

        ])
    }
}
