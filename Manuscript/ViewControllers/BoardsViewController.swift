//
//  AllBoardsViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/22/22.
//

import UIKit
import Combine
import Lottie

class BoardsViewController: UIViewController, UICollectionViewDelegate {
    
    weak var coordinator: BoardsCoordinator? = nil
    
    typealias DataSource = UICollectionViewDiffableDataSource<BoardViewControllerSection, BoardCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<BoardViewControllerSection, BoardCellModel>
    
    private lazy var myColectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.backgroundColor = Palette.lightBlack
        collectionView.refreshControl = refreshController
        return collectionView
    }()
    
    private let refreshController: UIRefreshControl = {
        let refreshController = UIRefreshControl()
        refreshController.attributedTitle = NSAttributedString("Refreshing the entire DB!")
        return refreshController
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
    
    private var tokens: Set<AnyCancellable> = []
    
    private let viewModel: BoardsViewModel
    
    init(viewModel: BoardsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func signOut(_ sender: UIBarButtonItem) {
        viewModel.signOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Palette.lightBlack
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItems = [
            
            UIBarButtonItem(image: Icon.rabbit, style: .plain, target: self, action: #selector(signOut(_:))),
            UIBarButtonItem(image: Icon.plus, style: .plain, target: self, action: #selector(createNewBoardBarButtonDidTap(_:))),
            UIBarButtonItem(image: Icon.selector, style: .plain, target: self, action: #selector(openWorkspaceSelectorBarButtonDidTap(_:))),
            
        ]
        
        refreshController.addTarget(self, action: #selector(refreshControllerDidPulled(_:)), for: .valueChanged)
        createBoardButton.addTarget(self, action: #selector(createNewBoardButtonDidTap(_:)), for: .touchUpInside)
        myColectionView.delegate = self
        
        viewModel.selectedWorkspacePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] workspaceBusinessModel in guard let self = self else { return }
                if self.refreshController.isRefreshing { self.refreshController.endRefreshing() }
                self.navigationItem.title = workspaceBusinessModel.title
                self.determineBoardPlaceholder(boards: workspaceBusinessModel.boards ?? [])
            }
            .store(in: &tokens)
        
        viewModel.boardsViewControllerUIEvent
            .receive(on: RunLoop.main)
            .sink { [weak self] event in guard let self = self else { return }
                
                if case .newBoardDidCreated = event {
                    self.coordinator?.dismissBoardCreationScreen()
                }
                
                if case .existingBoardDidDeleted = event {
                    self.coordinator?.dismissAllPresentedControllers()
                }
                
                if case .selectedWorkspaceDidChanged = event {
                    if let newlySelectedWorkspace = self.viewModel.selectedSpace {
                        self.navigationItem.title = newlySelectedWorkspace.title
                        self.determineBoardPlaceholder(boards: newlySelectedWorkspace.boards ?? [])
                    }
                    self.coordinator?.dismissWorspaceSelectorScreen()
                }
                
                if case .newSpaceDidCreated = event {
                    if let newlySelectedWorkspace = self.viewModel.selectedSpace {
                        self.navigationItem.title = newlySelectedWorkspace.title
                        self.determineBoardPlaceholder(boards: newlySelectedWorkspace.boards ?? [])
                    }
                    self.coordinator?.goBackFromWorkspaceCreationScreen()
                    
                }
                
                if case .signOutDidFinished = event {
                    self.coordinator?.signeOut()
                }
                
            }
            .store(in: &tokens)
        
        viewModel.fetchLocalDatabaseAndNotifyAllSubscribers()
    }
    
    @objc private func refreshControllerDidPulled(_ sender: UIBarButtonItem) {
        viewModel.syncTheCloud()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in guard let self = self else { return }
            if self.refreshController.isRefreshing { self.refreshController.endRefreshing() }
        }
    }
    
    @objc private func openWorkspaceSelectorBarButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.presentWorkspaceSelectorScreen()
    }
    
    @objc private func createNewBoardBarButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.presentBoardCreateEditScreen(state: .creation)
    }
    
    @objc private func createNewBoardButtonDidTap(_ sender: UIButton) {
        coordinator?.presentBoardCreateEditScreen(state: .creation)
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, layoutEnvironment in
            
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
            cell.model = itemIdentifier
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedItemId = dataSource.itemIdentifier(for: indexPath)?.remoteId {
            viewModel.selectNewBoard(id: Int64(selectedItemId)!)
            coordinator?.navigateToBoardDetail()
        }
        
    }
    
    private func determineBoardPlaceholder(boards: [BoardBusinessModel]) {
        
        if boards.count > 0 {
            
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
            applySnapshot(items: BoardTransformer.transformBoardsToCellModel(boards: boards), animatingDifferences: true)
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
}

enum BoardViewControllerSection {
    case main
}

struct BoardCellModel: Hashable {
    let remoteId: String
    let boardTitle: String
    let numberOfTasks: Int
    let imageIcon: String
    let isLatestChangeSynced: Bool
    
    init(remoteId: String, boardTitle: String, numberOfTasks: Int, imageIcon: String, isSynced: Bool) {
        self.remoteId = remoteId
        self.boardTitle = boardTitle
        self.numberOfTasks = numberOfTasks
        self.imageIcon = imageIcon
        self.isLatestChangeSynced = isSynced
    }
}


class BoardCollectionViewCell: UICollectionViewCell {
    
    var model: BoardCellModel?
//    weak var delegate: KaleidoscopeProtocol?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var newConfiguration = BoardCellContentConfiguration().updated(for: state)
        guard let binding = model else { return }
        newConfiguration.model = binding
//        newConfiguration.delegate = delegate
        contentConfiguration = newConfiguration
    }
}


struct BoardCellContentConfiguration: UIContentConfiguration {
    
    var model: BoardCellModel?
//    weak var delegate: KaleidoscopeProtocol?
    
    func makeContentView() -> UIView & UIContentView {
        let view = BoardCellContentView(configuration: self)
//        view.delegate = delegate
        return view
    }
    
    func updated(for state: UIConfigurationState) -> BoardCellContentConfiguration {
        var updatedConfiguration = self
        updatedConfiguration.model = model
        return updatedConfiguration
    }
}

class BoardCellContentView: UIView, UIContentView {
    
    var model: BoardCellModel?
    //    weak var delegate: KaleidoscopeProtocol?
    
    var configuration: UIContentConfiguration {
        didSet {
            applyConfiguration(configuration: configuration)
        }
    }
    
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
    
    init(configuration: BoardCellContentConfiguration) {
        self.configuration = configuration
        self.model = configuration.model
        super.init(frame: .zero)
        
        layer.cornerRadius = 19
        addSubview(iconImageView)
        addSubview(syncIndicatorImageView)
        addSubview(titleLabel)
        addSubview(numberOfTasksLabel)

        
        backgroundColor = Palette.mediumDarkGray
        
        
        NSLayoutConstraint.activate([
            numberOfTasksLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            numberOfTasksLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            numberOfTasksLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            numberOfTasksLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 25),
            
            titleLabel.bottomAnchor.constraint(equalTo: numberOfTasksLabel.topAnchor, constant: -8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            numberOfTasksLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            
            syncIndicatorImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            syncIndicatorImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            syncIndicatorImageView.heightAnchor.constraint(equalToConstant: 10),
            syncIndicatorImageView.widthAnchor.constraint(equalToConstant: 10),
            
        ])
        
        applyConfiguration(configuration: configuration)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyConfiguration(configuration: UIContentConfiguration) {
        guard let config = configuration as? BoardCellContentConfiguration, let model = config.model else { return }
        self.model = model
        
        iconImageView.image = UIImage(systemName: model.imageIcon)
        titleLabel.text = model.boardTitle
        
        if model.numberOfTasks > 1 {
            numberOfTasksLabel.text = "\(model.numberOfTasks) Tasks"
        } else {
            numberOfTasksLabel.text = "\(model.numberOfTasks) Task"
        }

        if model.isLatestChangeSynced {
            syncIndicatorImageView.tintColor = Palette.mediumDarkGray
        } else {
            syncIndicatorImageView.tintColor = Palette.magenta
        }

    }


}
