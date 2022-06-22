//
//  KaleidoscopeCellProvider.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/19/22.
//

import UIKit

struct KaleidoscopeCellProvider {
    
    static func provideCardCell(delegate: KaleidoscopeProtocol) -> UICollectionView.CellRegistration<CardCell, KaleidoscopeModel> {
        let cell = UICollectionView.CellRegistration<CardCell, KaleidoscopeModel> { cell, indexPath, itemIdentifier in
            cell.model = itemIdentifier.cardContentModel
            cell.delegate = delegate
        }
        return cell
    }
    
    static func provideInputCell(delegate: KaleidoscopeProtocol) -> UICollectionView.CellRegistration<InputCardCell, KaleidoscopeModel> {
        let cell = UICollectionView.CellRegistration<InputCardCell, KaleidoscopeModel> { cell, indexPath, itemIdentifier in
            cell.model = itemIdentifier.inputCardContentModel
            cell.delegate = delegate
        }
        return cell
    }
}

