//
//  KaleidoscopeProtocol.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/19/22.
//

import Foundation

enum KaleidoscopeProtocolAction {
    case checkBoxDidClicked(item: CardContentModel)
}

protocol KaleidoscopeProtocol: NSObject {
    func actionDidHappen(action: KaleidoscopeProtocolAction)
}
