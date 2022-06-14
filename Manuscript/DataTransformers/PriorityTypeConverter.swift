//
//  PriorityTypeConverter.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/13/22.
//

import Foundation

struct PriorityTypeConverter {
    
    static func getString(priority: Priority) -> String {
        if priority == .low {
            return "low"
        }
        
        if priority == .medium {
            return "medium"
        }
        
        if priority == .high {
            return "high"
        }
        return "Low"
    }
    
    static func getEnum(priority: String) -> Priority {
        
        if priority.lowercased() == "low" { return Priority.low}
        if priority.lowercased() == "medium" { return Priority.medium}
        if priority.lowercased() == "high" { return Priority.high}
        
        return Priority.low
    }
}
