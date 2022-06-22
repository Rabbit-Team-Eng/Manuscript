//
//  KaleidoscopeViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/20/22.
//

import UIKit

class KaleidoscopeViewController: UIViewController, KaleidoscopeProtocol, UICollectionViewDelegate {
    func actionDidHappen(action: KaleidoscopeProtocolAction) {
        
    }
    
    
    typealias DataSource = UICollectionViewDiffableDataSource<KaleidoscopeSection, KaleidoscopeModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<KaleidoscopeSection, KaleidoscopeModel>
    
    private lazy var myColectionView: UICollectionView = {
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        layoutConfig.showsSeparators = false
        layoutConfig.backgroundColor = Palette.lightBlack
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        let collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: listLayout)
        collectionView.allowsSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    lazy var dataSource = createDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(myColectionView)
        myColectionView.delegate = self
        view.backgroundColor = Palette.lightBlack

        NSLayoutConstraint.activate([
            myColectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            myColectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            myColectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            myColectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
    
    func createDataSource() -> DataSource {
        let cardCell = KaleidoscopeCellProvider.provideCardCell(delegate: self)
        let inputCell = KaleidoscopeCellProvider.provideInputCell(delegate: self)

        let dataSource = DataSource(collectionView: myColectionView) { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier.section {
            case .card:
                return collectionView.dequeueConfiguredReusableCell(using: cardCell, for: indexPath, item: itemIdentifier)
            case .input:
                return collectionView.dequeueConfiguredReusableCell(using: inputCell, for: indexPath, item: itemIdentifier)
            }
        }
        return dataSource
    }

    func applySnapshot(items: [KaleidoscopeModel], isAnimated: Bool) {
        
    }

}

class MembersViewController: KaleidoscopeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applySnapshot(items: [
        
            KaleidoscopeModel(id: "0", section: .card, cardContentModel: CardContentModel(firstImageSource: "trash",
                                                                                          secondImageSource: nil,
                                                                                          title: "Title",
                                                                                          description: nil,
                                                                                          imagePosition: .left)),
            
            KaleidoscopeModel(id: "1", section: .card, cardContentModel: CardContentModel(firstImageSource: "aqi.medium",
                                                                                          secondImageSource: nil,
                                                                                          title: "Another Title",
                                                                                          description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                                                                                          imagePosition: .left)),
            
            KaleidoscopeModel(id: "2", section: .input, inputCardContentModel: InputCardCellModel(firstText: "firstText",
                                                                                                  firstPlaceholder: nil,
                                                                                                  firstIsInteractionsEnabled: true,
                                                                                                  secondText: "secondText",
                                                                                                  secondPlaceholder: nil,
                                                                                                  secondIsInteractionsEnabled: true)),
            
            KaleidoscopeModel(id: "3", section: .card, cardContentModel: CardContentModel(firstImageSource: "square",
                                                                                          secondImageSource: "chevron.up.square.fill",
                                                                                          title: "Title",
                                                                                          description: nil,
                                                                                          imagePosition: .left)),
            
        ], isAnimated: true)
        
    }
    
    override func applySnapshot(items: [KaleidoscopeModel], isAnimated: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([.card, .input])
        
        snapshot.appendItems(items.filter { $0.section == .card }, toSection: .card)

        snapshot.appendItems(items.filter { $0.section == .input }, toSection: .input)

        dataSource.apply(snapshot, animatingDifferences: isAnimated)
    }
    
    override func actionDidHappen(action: KaleidoscopeProtocolAction) {
        if case .checkBoxDidClicked(let model) = action {
            
            var snapshot = dataSource.snapshot()
            var item = snapshot.itemIdentifiers.first { $0.id == "3" }!
            item.cardContentModel!.firstImageSource = "trash"
            snapshot.reconfigureItems([
                item,
            ])
        }
    }
}
