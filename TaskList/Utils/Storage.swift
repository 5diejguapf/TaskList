//
//  Storage.swift
//  TaskList
//
//  Created by serg on 24.08.2023.
//

import CoreData
import UIKit

class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetchData() -> [Task] {
        do {
            return try viewContext.fetch(Task.fetchRequest())
        } catch {
            print(error)
            return []
        }
    }
    
    private func saveContent() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    func createTask(withTitle: String) -> Task {
        let task = Task(context: viewContext)
        task.title = withTitle
        saveContent()
        return task
    }
    
    func update() {
        saveContent()
    }
    
    func delete(task: Task) {
        viewContext.delete(task)
        saveContent()
    }
}
