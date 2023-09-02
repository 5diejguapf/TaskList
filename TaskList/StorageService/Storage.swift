//
//  Storage.swift
//  TaskList
//
//  Created by serg on 24.08.2023.
//

import CoreData
//import UIKit

class StorageManager {
    static let shared = StorageManager()
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let viewContext : NSManagedObjectContext
    
    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    func fetchData(completionHandler: @escaping (Result<[Task], Error>) -> Void) {
        do {
            let tasks = try viewContext.fetch(Task.fetchRequest())
            completionHandler(.success(tasks))
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createTask(withTitle: String, completion: (Task) -> Void) {
        let task = Task(context: viewContext)
        task.title = withTitle
        completion(task)
        saveContext()
    }
    
    func update(_ task: Task, title: String) {
        task.title = title
        saveContext()
    }
    
    func delete(task: Task) {
        viewContext.delete(task)
        saveContext()
    }
}
