//
//  KaleidoscopeCellProvider.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/19/22.
//

import UIKit

struct KaleidoscopeCellProvider {
    
    func provideCardCell(delegate: KaleidoscopeProtocol) -> UICollectionView.CellRegistration<CardCell, KaleidoscopeModel> {
        return .init { cell, indexPath, itemIdentifier in
            cell.model = itemIdentifier.cardContentModel
            cell.delegate = delegate
        }
    }
}

