//
//  PrioritySelectorViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import UIKit

class PrioritySelectorViewController: UIViewController, UICollectionViewDelegate {
    
    weak var parentCoordinator: TabBarCoordinator? = nil
    
    typealias DataSource = UICollectionViewDiffableDataSource<TaskDetailSectionType, TaskDetailCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<TaskDetailSectionType, TaskDetailCellModel>
    
    lazy var dataSource = createDataSource()
    
    lazy var myColectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = Palette.lightBlack
        return collectionView
    }()

    private let selectNewPriorityButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.title = "Set Priority"
        button.contentHorizontalAlignment = .center
        button.configuration?.baseBackgroundColor = Palette.blue
        button.setTitleColor(Palette.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.lightBlack
        
        view.addSubview(selectNewPriorityButton)
        view.addSubview(myColectionView)
        
        myColectionView.delegate = self
        
        myColectionView.register(TaskGeneralInfoSectionHeaderView.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                 withReuseIdentifier: TaskGeneralInfoSectionHeaderView.reuseIdentifier)
        
        selectNewPriorityButton.addTarget(self, action: #selector(newPriorityDidSelected(_:)), for: .touchUpInside)
        
        applySnapshot(items:[
            TaksSectionProvider.providePrioritySection(id: "0", priority: .low, isHighlighted: false),
            TaksSectionProvider.providePrioritySection(id: "1", priority: .medium, isHighlighted: false),
            TaksSectionProvider.providePrioritySection(id: "2", priority: .high, isHighlighted: false),
        ])
        
        if let priority = taskFlowInteractor.selectedPriority {
            switch priority {
            case .low:
                myColectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
            case .medium:
                myColectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: true, scrollPosition: .top)
            case .high:
                myColectionView.selectItem(at: IndexPath(item: 2, section: 0), animated: true, scrollPosition: .top)
            }
        }
    }
    
    @objc private func newPriorityDidSelected(_ sender: UIButton) {
        if let selectedIndex = myColectionView.indexPathsForSelectedItems?.first,
           let cellModel = dataSource.itemIdentifier(for: selectedIndex),
           let priority = cellModel.priorityCellModel?.priority {
            
            taskFlowInteractor.selectNewPriority(priority: priority)
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate([
            
            myColectionView.bottomAnchor.constraint(equalTo: selectNewPriorityButton.topAnchor, constant: -32),
            myColectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            myColectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            myColectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),

            
            selectNewPriorityButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            selectNewPriorityButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            selectNewPriorityButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            selectNewPriorityButton.heightAnchor.constraint(equalToConstant: 50)
        
        ])
    }
    
    private let mainViewModel: BoardsViewModel
    private let taskFlowInteractor: TaskFlowInteractor

    init(mainViewModel: BoardsViewModel, taskFlowInteractor: TaskFlowInteractor) {
        self.mainViewModel = mainViewModel
        self.taskFlowInteractor = taskFlowInteractor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {

    }


}

extension PrioritySelectorViewController {
    
    
    func applySnapshot(items: [TaskDetailCellModel], animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.prioritySection])

        items.forEach { item in
       
            if item.priorityCellModel != nil {
                snapshot.appendItems([item], toSection: .prioritySection)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in
            guard let self = self else { return }
            
//            if let priority = self.boardViewModel.selectedPriority?.priority {
//                
//                if priority == .low {
//                    self.myColectionView.selectItem(at: IndexPath(item: 2, section: 0), animated: false, scrollPosition: [])
//                } else if priority == .medium {
//                    self.myColectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: false, scrollPosition: [])
//                } else if priority == .high {
//                    self.myColectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
//                }
//                
//            } else {
//                self.myColectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
//            }
        }
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, layoutEnvironment in

            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]

            switch section {
            case .prioritySection:
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
        sectionHeader.pinToVisibleBounds = false
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.boundarySupplementaryItems = [sectionHeader]
        return layoutSection
    }

    
    func prioritySelectorCellRegistration() -> UICollectionView.CellRegistration<PrioritySelectorCell, TaskDetailCellModel> {
        return .init { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            cell.model = itemIdentifier.priorityCellModel
        }
    }

    
    func createDataSource() -> DataSource {
        let priorityCell = prioritySelectorCellRegistration()

        let dataSource = DataSource(collectionView: myColectionView) { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier.section {
            case .prioritySection:
                return collectionView.dequeueConfiguredReusableCell(using: priorityCell, for: indexPath, item: itemIdentifier)
            default:
                fatalError()
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .prioritySection:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskGeneralInfoSectionHeaderView.reuseIdentifier, for: indexPath) as? TaskGeneralInfoSectionHeaderView
                view?.titleLabel.text = section.sectionHeaderTitle
                return view
            default:
                fatalError()

            }
        }
        return dataSource
    }
}
