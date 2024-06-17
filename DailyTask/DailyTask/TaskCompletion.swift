//
//  TaskCompletion.swift
//  DailyTask
//
//  Created by Eric Spencer on 5/28/24.
//

import Foundation
import CoreData

@objc(TaskCompletion)
public class TaskCompletion: NSManagedObject {
    @NSManaged public var taskId: UUID
    @NSManaged public var completionDate: Date
}
