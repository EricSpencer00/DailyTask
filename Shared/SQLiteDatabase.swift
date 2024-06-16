//
//  SQLiteDatabase.swift
//  DailyTask
//
//  Created by Eric Spencer on 5/31/24.
//

import SQLite3
import Foundation

class DatabaseManager {
    private var db: OpaquePointer?
    
    init() {
        setUpDatabase()
        createTables()
    }
    
    private func setUpDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("tasks.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
    }
    
    private func createTables() {
        let createTasksTableQuery = """
        CREATE TABLE IF NOT EXISTS tasks (
            id TEXT PRIMARY KEY,
            name TEXT,
            isCompleted INTEGER,
            emoji TEXT,
            urgency TEXT
        );
        """
        
        let createDatesTableQuery = """
        CREATE TABLE IF NOT EXISTS dates (
            id TEXT PRIMARY KEY,
            taskId TEXT,
            date REAL,
            FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE CASCADE
        );
        """
        
        if sqlite3_exec(db, createTasksTableQuery, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating tasks table: \(errmsg)")
        }
        
        if sqlite3_exec(db, createDatesTableQuery, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating dates table: \(errmsg)")
        }
    }
    
    func insertTask(task: Task) {
        let insertQuery = "INSERT INTO tasks (id, name, isCompleted, emoji, urgency) VALUES (?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        sqlite3_bind_text(stmt, 1, task.id.uuidString, -1, nil)
        sqlite3_bind_text(stmt, 2, task.name, -1, nil)
        sqlite3_bind_int(stmt, 3, task.isCompleted ? 1 : 0)
        sqlite3_bind_text(stmt, 4, task.emoji, -1, nil)
        sqlite3_bind_text(stmt, 5, task.urgency.rawValue, -1, nil)
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error inserting task: \(errmsg)")
        }
        
        sqlite3_finalize(stmt)
    }
    
    func getTaskById(taskId: UUID) -> Task? {
        let query = "SELECT id, name, isCompleted, emoji, urgency FROM tasks WHERE id = ?;"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return nil
        }
        
        sqlite3_bind_text(stmt, 1, taskId.uuidString, -1, nil)
        
        var task: Task?
        if sqlite3_step(stmt) == SQLITE_ROW {
            let id = UUID(uuidString: String(cString: sqlite3_column_text(stmt, 0)))!
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let isCompleted = sqlite3_column_int(stmt, 2) == 1
            let emoji = String(cString: sqlite3_column_text(stmt, 3))
            let urgency = Urgency(rawValue: String(cString: sqlite3_column_text(stmt, 4)))!
            
            //task = Task(id: id, name: name, urgency: urgency, isCompleted: isCompleted, emoji: emoji)
        }
        
        sqlite3_finalize(stmt)
        return task
    }
    
    func updateTask(task: Task) {
        let updateQuery = "UPDATE tasks SET name = ?, isCompleted = ?, emoji = ?, urgency = ? WHERE id = ?;"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateQuery, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing update: \(errmsg)")
            return
        }
        
        sqlite3_bind_text(stmt, 1, task.name, -1, nil)
        sqlite3_bind_int(stmt, 2, task.isCompleted ? 1 : 0)
        sqlite3_bind_text(stmt, 3, task.emoji, -1, nil)
        sqlite3_bind_text(stmt, 4, task.urgency.rawValue, -1, nil)
        sqlite3_bind_text(stmt, 5, task.id.uuidString, -1, nil)
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error updating task: \(errmsg)")
        }
        
        sqlite3_finalize(stmt)
    }
    
    func deleteTask(taskId: UUID) {
        let deleteQuery = "DELETE FROM tasks WHERE id = ?;"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteQuery, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing delete: \(errmsg)")
            return
        }
        
        sqlite3_bind_text(stmt, 1, taskId.uuidString, -1, nil)
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error deleting task: \(errmsg)")
        }
        
        sqlite3_finalize(stmt)
    }
    
    func insertTaskDate(taskDate: TaskDate) {
        let insertQuery = "INSERT INTO dates (id, taskId, date) VALUES (?, ?, ?);"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert date: \(errmsg)")
            return
        }
        
        sqlite3_bind_text(stmt, 1, taskDate.id.uuidString, -1, nil)
        sqlite3_bind_text(stmt, 2, taskDate.taskId.uuidString, -1, nil)
        sqlite3_bind_double(stmt, 3, taskDate.date.timeIntervalSince1970)
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error inserting task date: \(errmsg)")
        }
        
        sqlite3_finalize(stmt)
    }
    
    func getTaskDates(taskId: UUID) -> [TaskDate] {
        let query = "SELECT id, taskId, date FROM dates WHERE taskId = ?;"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select dates: \(errmsg)")
            return []
        }
        
        sqlite3_bind_text(stmt, 1, taskId.uuidString, -1, nil)
        
        var taskDates: [TaskDate] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = UUID(uuidString: String(cString: sqlite3_column_text(stmt, 0)))!
            let taskId = UUID(uuidString: String(cString: sqlite3_column_text(stmt, 1)))!
            let date = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 2))
            
            taskDates.append(TaskDate(id: id, taskId: taskId, date: date))
        }
        
        sqlite3_finalize(stmt)
        return taskDates
    }
    
    func deleteTaskDates(taskId: UUID) {
        let deleteQuery = "DELETE FROM dates WHERE taskId = ?;"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteQuery, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing delete dates: \(errmsg)")
            return
        }
        
        sqlite3_bind_text(stmt, 1, taskId.uuidString, -1, nil)
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error deleting task dates: \(errmsg)")
        }
        
        sqlite3_finalize(stmt)
    }
}
