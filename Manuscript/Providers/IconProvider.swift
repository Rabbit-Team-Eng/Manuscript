//
//  IconProvider.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/13/22.
//

import Foundation

struct IconProvider {
    
    static func icons(selectedIcon: String?) -> [IconSelectorCellModel] {
        let icons = [
            
            IconSelectorCellModel(id: "square.and.arrow.up.on.square", iconResource: "square.and.arrow.up.on.square"),
            IconSelectorCellModel(id: "pencil.circle.fill", iconResource: "pencil.circle.fill"),
            IconSelectorCellModel(id: "pencil.tip", iconResource: "pencil.tip"),
            IconSelectorCellModel(id: "lasso", iconResource: "lasso"),
            IconSelectorCellModel(id: "trash", iconResource: "trash"),
            IconSelectorCellModel(id: "folder", iconResource: "folder"),
            IconSelectorCellModel(id: "paperplane.circle", iconResource: "paperplane.circle"),
            IconSelectorCellModel(id: "externaldrive.badge.minus", iconResource: "externaldrive.badge.minus"),
            IconSelectorCellModel(id: "doc.on.clipboard.fill", iconResource: "doc.on.clipboard.fill"),
            IconSelectorCellModel(id: "doc.text.below.ecg", iconResource: "doc.text.below.ecg"),
            IconSelectorCellModel(id: "text.book.closed", iconResource: "text.book.closed"),
            IconSelectorCellModel(id: "greetingcard", iconResource: "greetingcard"),
            IconSelectorCellModel(id: "person", iconResource: "person"),
            IconSelectorCellModel(id: "command.square.fill", iconResource: "command.square.fill"),
            IconSelectorCellModel(id: "globe", iconResource: "globe"),
            IconSelectorCellModel(id: "calendar.day.timeline.trailing", iconResource: "calendar.day.timeline.trailing"),
            IconSelectorCellModel(id: "arrowshape.bounce.right", iconResource: "arrowshape.bounce.right"),
            IconSelectorCellModel(id: "book.closed", iconResource: "book.closed"),
            IconSelectorCellModel(id: "newspaper.circle", iconResource: "newspaper.circle"),
            IconSelectorCellModel(id: "rosette", iconResource: "rosette"),
            IconSelectorCellModel(id: "graduationcap.fill", iconResource: "graduationcap.fill"),
            IconSelectorCellModel(id: "paperclip.badge.ellipsis", iconResource: "paperclip.badge.ellipsis"),
            IconSelectorCellModel(id: "personalhotspot", iconResource: "personalhotspot"),
            IconSelectorCellModel(id: "rectangle.inset.filled.and.person.filled", iconResource: "rectangle.inset.filled.and.person.filled"),
            IconSelectorCellModel(id: "person.fill.and.arrow.left.and.arrow.right", iconResource: "person.fill.and.arrow.left.and.arrow.right"),
            IconSelectorCellModel(id: "sun.max.fill", iconResource: "sun.max.fill"),
            IconSelectorCellModel(id: "moon.zzz", iconResource: "moon.zzz"),
            IconSelectorCellModel(id: "cloud.sleet.fill", iconResource: "cloud.sleet.fill"),
            IconSelectorCellModel(id: "smoke", iconResource: "smoke"),
            IconSelectorCellModel(id: "umbrella.fill", iconResource: "umbrella.fill"),
            IconSelectorCellModel(id: "cursorarrow.and.square.on.square.dashed", iconResource: "cursorarrow.and.square.on.square.dashed"),
            IconSelectorCellModel(id: "rectangle.grid.2x2", iconResource: "rectangle.grid.2x2"),
            IconSelectorCellModel(id: "circle.grid.3x3", iconResource: "circle.grid.3x3"),
            IconSelectorCellModel(id: "circle.hexagongrid", iconResource: "circle.hexagongrid"),
            IconSelectorCellModel(id: "seal.fill", iconResource: "seal.fill"),
            IconSelectorCellModel(id: "exclamationmark.triangle", iconResource: "exclamationmark.triangle"),
            IconSelectorCellModel(id: "play.fill", iconResource: "play.fill"),
            IconSelectorCellModel(id: "memories.badge.plus", iconResource: "memories.badge.plus"),
            IconSelectorCellModel(id: "infinity.circle", iconResource: "infinity.circle"),
            IconSelectorCellModel(id: "speaker.zzz.fill", iconResource: "speaker.zzz.fill"),
        ]
        
        if let selectedIcon = selectedIcon {
            var allOtherIcon =  icons.filter { $0.iconResource != selectedIcon }
            allOtherIcon.insert(IconSelectorCellModel(id: selectedIcon, iconResource: selectedIcon), at: 0)
            return allOtherIcon
        }
        
        return icons
    }
}
