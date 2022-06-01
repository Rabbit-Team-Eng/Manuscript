//
//  DatabaseManager.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/7/22.
//

import Combine
import CoreData

protocol DataSyncronizer {
    associatedtype Model where Model : BusinessModelProtocol
    
    func syncronize(items: [ComparatorResult<Model>], completion: @escaping () -> Void)
}



