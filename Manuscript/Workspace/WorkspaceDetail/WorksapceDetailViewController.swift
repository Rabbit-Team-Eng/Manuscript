//
//  WorksapceCreateViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/8/22.
//

import UIKit

class WorksapceDetailViewController: UIViewController, WorkspaceDetailActionsProtocol {
    
    func actionDidHappen(action: WorkspaceDetailAction) {
        
    }
    
    lazy var myColectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = Palette.lightBlack
        return collectionView
    }()
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            
            switch section {
            case .generalInformationSection:
                return self.createGeneralInfoSectionLayout()
            default:
                fatalError()
            }
        }
        
        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()
        return layout
    }
    
    func applySnapshot(items: [WorkspaceDetailCellModel], animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.generalInformationSection])
        
        items.forEach { item in
            
            if item.generalInformationCellModel != nil {
                snapshot.appendItems([item], toSection: .generalInformationSection)
                return
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func createGeneralInfoSectionLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
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
    
    typealias DataSource = UICollectionViewDiffableDataSource<WorksapceDetailSection, WorkspaceDetailCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<WorksapceDetailSection, WorkspaceDetailCellModel>
    
    lazy var dataSource = createDataSource()
    
    func generalInfoCellRegistration() -> UICollectionView.CellRegistration<GeneralInfoCell, WorkspaceDetailCellModel> {
        return .init { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else {return}
            cell.model = itemIdentifier.generalInformationCellModel
            cell.delegate = self
        }
    }
    
    func createDataSource() -> DataSource {
        let generalInfoCell = generalInfoCellRegistration()
        
        let dataSource = DataSource(collectionView: myColectionView) { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier.section {
            case .generalInformationSection:
                return collectionView.dequeueConfiguredReusableCell(using: generalInfoCell, for: indexPath, item: itemIdentifier)
            default:
                fatalError()
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .generalInformationSection:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GeneralInfoSectionHeaderView.reuseIdentifier, for: indexPath) as? GeneralInfoSectionHeaderView
                view?.titleLabel.text = section.sectionHeaderTitle
                return view
            default:
                fatalError()

            }
        }
        return dataSource
    }

    private let workspacesViewModel: WorkspacesViewModel
    private let worksapceDetailState: WorksapceDetailState
    
    weak var coordinator: BoardsCoordinator? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Palette.gray
        view.addSubview(myColectionView)
        myColectionView.register(GeneralInfoSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GeneralInfoSectionHeaderView.reuseIdentifier)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward.square"), style: .plain, target: self, action: #selector(backButtonDidTap(_:)))
        
        if case .create = worksapceDetailState {
            navigationItem.title = "Create new workspace"
        }
        
        if case .view(let workspace) = worksapceDetailState {
            navigationItem.title = workspace.title
            applySnapshot(items: WorkspaceTransformer.transformWorkspacesToSelectorCellModel(workspace: workspace))
        }
        
        if case .edit(let workspace) = worksapceDetailState {
            navigationItem.title = workspace.title
            applySnapshot(items: WorkspaceTransformer.transformWorkspacesToSelectorCellModel(workspace: workspace))
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate([
            myColectionView.topAnchor.constraint(equalTo: navigationController?.navigationBar.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor, constant: 16),
            myColectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            myColectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            myColectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
    }
    
    @objc private func backButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.goBackFromWorkspaceCreationScreen()
    }
    
    init(workspacesViewModel: WorkspacesViewModel, worksapceDetailState: WorksapceDetailState) {
        self.workspacesViewModel = workspacesViewModel
        self.worksapceDetailState = worksapceDetailState
        print("AVERAKEDABRA: ALLOC -> WorksapceDetailViewController")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    deinit {
        print("AVERAKEDABRA: RELEASE -> WorksapceDetailViewController")
    }

}
