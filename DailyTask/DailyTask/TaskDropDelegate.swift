//
//  TaskDropDelegate.swift
//  DailyTask
//
//  Created by Eric Spencer on 5/28/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct TaskDropDelegate: DropDelegate {
    let task: Task
    @Binding var tasks: [Task]
    let currentUrgency: Urgency
    
    @State private var isHovered: Bool = false

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [UTType.text])
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [UTType.text]).first else { return false }

        item.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data as? Data,
                      let uuidString = String(data: data, encoding: .utf8),
                      let uuid = UUID(uuidString: uuidString),
                      let draggedTaskIndex = tasks.firstIndex(where: { $0.id == uuid }) else { return }

                tasks[draggedTaskIndex].urgency = currentUrgency
            }
        }
        return true
    }

    func dropEntered(info: DropInfo) {
        isHovered = true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func dropExited(info: DropInfo) {
        isHovered = false
    }
}
