//
//  CardContentModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/19/22.
//

import Foundation

struct CardContentModel: Hashable {
    var firstImageSource: String
    var secondImageSource: String?
    let title: String
    let description: String?
    let imagePosition: CardCellImagePosition
}
