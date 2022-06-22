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
        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, layoutEnvironment in
            
            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            
            switch section {
            case .generalInformationSection:
                return self.createGeneralInfoSectionLayout()
            case .sharingSection:
                return self.createManageAcessSectionLayout()
            default:
                fatalError()
            }
        }
        
        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()
        return layout
    }
    
    func createManageAcessSectionLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(64))
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
    
    func applySnapshot(items: [WorkspaceDetailCellModel], animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        
        if case .create = worksapceDetailState {
            snapshot.appendSections([.generalInformationSection])

        }
        
        if case .view = worksapceDetailState {
            snapshot.appendSections([.generalInformationSection, .sharingSection])
        }
                
        items.forEach { item in
            
            if item.generalInformationCellModel != nil {
                snapshot.appendItems([item], toSection: .generalInformationSection)
            }
            
            if item.manageAccessCellModel != nil {
                snapshot.appendItems([item], toSection: .sharingSection)
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
            guard let self = self else { return }
            cell.model = itemIdentifier.generalInformationCellModel
            cell.delegate = self
        }
    }
    
    func manageAccessCellRegistration() -> UICollectionView.CellRegistration<ManageAccessCell, WorkspaceDetailCellModel> {
        return .init { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            cell.model = itemIdentifier.manageAccessCellModel
            cell.delegate = self
        }
    }
    
    func createDataSource() -> DataSource {
        let generalInfoCell = generalInfoCellRegistration()
        let manageAccessCell = manageAccessCellRegistration()
        
        let dataSource = DataSource(collectionView: myColectionView) { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier.section {
            case .generalInformationSection:
                return collectionView.dequeueConfiguredReusableCell(using: generalInfoCell, for: indexPath, item: itemIdentifier)
            case .sharingSection:
                return collectionView.dequeueConfiguredReusableCell(using: manageAccessCell, for: indexPath, item: itemIdentifier)
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
            case .sharingSection:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ManageAccessSectionHeaderView.reuseIdentifier, for: indexPath) as? ManageAccessSectionHeaderView
                view?.titleLabel.text = section.sectionHeaderTitle
                return view
            default:
                fatalError()

            }
        }
        return dataSource
    }

    private let mainViewModel: MainViewModel
    private let worksapceDetailState: WorksapceDetailState
    
    weak var coordinator: BoardsCoordinator? = nil
    
    private let primaryBottomButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.title = "Create New Workspace"
        button.contentHorizontalAlignment = .center
        button.configuration?.baseBackgroundColor = Palette.mediumDarkGray
        button.setTitleColor(Palette.white, for: .normal)
        button.configuration?.cornerStyle = .large
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Palette.lightBlack
        view.addSubview(myColectionView)
        view.addSubview(primaryBottomButton)

        myColectionView.register(GeneralInfoSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GeneralInfoSectionHeaderView.reuseIdentifier)
        
        myColectionView.register(ManageAccessSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ManageAccessSectionHeaderView.reuseIdentifier)
        

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward.square"), style: .plain, target: self, action: #selector(backButtonDidTap(_:)))
        
        if case .create = worksapceDetailState {
            navigationItem.title = "Create new workspace"
            primaryBottomButton.setTitle("Create New Worksapce", for: .normal)
            applySnapshot(items: [WorkspaceDetailCellModel(id: "0", generalInformationCellModel: GeneralInfoCellModel(title: "", description: "", isEditable: true, needPlaceholders: true))])
        }
        
        if case .view(let workspace) = worksapceDetailState {
            navigationItem.title = workspace.title
            primaryBottomButton.setTitle("Leave / Delete Worksapce", for: .normal)
            applySnapshot(items: WorkspaceTransformer.transformWorkspacesToSelectorCellModel(workspace: workspace))
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate([
            myColectionView.topAnchor.constraint(equalTo: navigationController?.navigationBar.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor, constant: 16),
            myColectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            myColectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            myColectionView.bottomAnchor.constraint(equalTo: primaryBottomButton.topAnchor, constant: -32),
            
            primaryBottomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            primaryBottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            primaryBottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            primaryBottomButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
    }
    
    @objc private func backButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.goBackFromWorkspaceCreationScreen()
    }
    
    init(mainViewModel: MainViewModel, worksapceDetailState: WorksapceDetailState) {
        self.mainViewModel = mainViewModel
        self.worksapceDetailState = worksapceDetailState
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    deinit {

    }

}
