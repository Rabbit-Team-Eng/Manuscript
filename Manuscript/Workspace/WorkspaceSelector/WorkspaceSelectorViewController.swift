//
//  WorkspaceSelectorViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/5/22.
//

import UIKit
import Combine

class WorkspaceSelectorViewController: UIViewController, WorkspaceSelectorProtocol {
    
    typealias DataSource = UICollectionViewDiffableDataSource<WorkspaceSelectorSectionType, WorkspaceSelectorCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<WorkspaceSelectorSectionType, WorkspaceSelectorCellModel>

    private lazy var dataSource = createDataSource()
    private var tokens: Set<AnyCancellable> = []
    private var currentWorksapces: [WorkspaceBusinessModel] = []

    weak var parentCoordinator: TabBarCoordinator? = nil

    private let createNewWorkspaceButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.title = "Create new space"
        button.configuration?.image = UIImage(systemName: "plus.square")
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 8
        button.contentHorizontalAlignment = .left
        button.setTitleColor(Palette.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // TODO: Check how to avoid lazy
    private lazy var myColectionView: UICollectionView = {
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        layoutConfig.showsSeparators = false
        layoutConfig.backgroundColor = Palette.lightBlack
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        let collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: listLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let switchWorkspaceButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.title = "Switch to selected space"
        button.contentHorizontalAlignment = .center
        button.configuration?.baseBackgroundColor = Palette.blue
        button.setTitleColor(Palette.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let workspacesViewModel: WorkspacesViewModel

    init(workspacesViewModel: WorkspacesViewModel) {
        self.workspacesViewModel = workspacesViewModel
        print("AVERAKEDABRA: ALLOC -> WorkspaceSelectorViewController")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    deinit {
        print("AVERAKEDABRA: RELEASE -> WorkspaceSelectorViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Palette.lightBlack
        view.addSubview(createNewWorkspaceButton)
        view.addSubview(myColectionView)
        view.addSubview(switchWorkspaceButton)
        navigationController?.isNavigationBarHidden = true
        
        createNewWorkspaceButton.addTarget(self, action: #selector(createNewWorkspaceButtonDidTap(_:)), for: .touchUpInside)
        switchWorkspaceButton.addTarget(self, action: #selector(workspaceDidSwitched(_:)), for: .touchUpInside)
        
        workspacesViewModel.events.sink { [weak self] workspaceEvent in guard let self = self else { return }
            
            switch workspaceEvent {
            case .workspacesDidFetch(let workspaces):
                self.currentWorksapces = workspaces
                self.applySnapshot(items: WorkspaceTransformer.transformWorkspacesToSelectorCellModel(workspaces: workspaces), withAnimation: true)
            }
        }
        .store(in: &tokens)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        workspacesViewModel.fetchWorkspaces()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate([
            createNewWorkspaceButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            createNewWorkspaceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createNewWorkspaceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createNewWorkspaceButton.heightAnchor.constraint(equalToConstant: 20),
            
            myColectionView.topAnchor.constraint(equalTo: createNewWorkspaceButton.bottomAnchor, constant: 32),
            myColectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            myColectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            myColectionView.bottomAnchor.constraint(equalTo: switchWorkspaceButton.topAnchor, constant: -32),

            switchWorkspaceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            switchWorkspaceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            switchWorkspaceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            switchWorkspaceButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func applySnapshot(items: [WorkspaceSelectorCellModel], withAnimation: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: withAnimation) { [weak self] in
            guard let self = self else { return }
            let firstItemIndexPathInCollectionView = IndexPath(item: 0, section: 0)
            if self.myColectionView.indexPathsForSelectedItems?.first == nil {
                self.myColectionView.selectItem(at: firstItemIndexPathInCollectionView, animated: false, scrollPosition: .top)
            }
        }
      
    }
    
    private func createDataSource() -> DataSource {
        let cell = workspaceSelectorCellRegistration()
        
        let dataSource = DataSource(collectionView: myColectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
            return cell
        }
            
        return dataSource
    }
    
    private func workspaceSelectorCellRegistration() -> UICollectionView.CellRegistration<WorkspaceSelectorCell, WorkspaceSelectorCellModel> {
        return .init { [weak self] cell, indexPath, itemIdentifier in
            cell.model = itemIdentifier
            cell.delegate = self
        }
    }
    
    func workspaceDetailFlowDidSelected(model: WorkspaceSelectorCellModel) {
        guard let selectedWorkspace = currentWorksapces.first(where: {  "\($0.remoteId)" == model.id }) else { return }
        parentCoordinator?.navigateToWorkspaceDetail(worksapceDetailState: .view(workspace: selectedWorkspace))
    }
    
    @objc private func createNewWorkspaceButtonDidTap(_ sender: UIButton) {
        parentCoordinator?.navigateToWorkspaceDetail(worksapceDetailState: .create)
    }
    
    @objc private func workspaceDidSwitched(_ sender: UIButton) {
        guard let getSelectedItemIndex = myColectionView.indexPathsForSelectedItems?.first?.item else { return }
        let item = dataSource.snapshot().itemIdentifiers[getSelectedItemIndex]
        UserDefaults.selectedWorkspaceId = item.id
        print("workspaceDidSwitched: \(item.id) | \(item.title)")
        parentCoordinator?.dismissWorspaceSelectorScreen()
        NotificationCenter.default.post(name: Notification.Name("NewWorkspaceDidSwitched"), object: nil)
    }

}
