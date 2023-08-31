//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 02.04.2023.
//

import UIKit

enum AlertAction {
    case addTask
    case editTask(Int)
}

class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private let storage = StorageManager.shared
    private var taskList: [Task] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        storage.fetchData { [weak self] tasks in
            self?.taskList = tasks
        }
    }
    
    private func addNewTask() {
        showAlert(.addTask, withTitle: "New Task", andMessage: "What do you want to do?")
    }
    
    private func editTask(_ at: Int) {
        showAlert(.editTask(at), withTitle: "Update Task", andMessage: "You can update your task")
    }
    
    private func showAlert(_ withAction: AlertAction, withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { _ in
            guard let taskTitle = alert.textFields?.first?.text, !taskTitle.isEmpty else { return }
            switch withAction {
            case .addTask:
                self.add(taskTitle)
            case .editTask(let at):
                self.update(taskTitle, at: at)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            switch withAction {
            case .addTask:
                textField.placeholder = "New Task"
            case .editTask(let at):
                textField.text = self.taskList[at].title
            }
        }
        present(alert, animated: true)
    }
    
    private func add(_ taskTitle: String) {
        taskList.append(storage.createTask(withTitle: taskTitle))
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    private func update(_ taskTitle: String, at: Int) {
        taskList[at].title = taskTitle
        storage.update(task: taskList[at])
        let indexPath = IndexPath(row: at, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func remove(_ at: Int) {
        guard at >= 0 && at < taskList.count else { return }
        let indexPath = IndexPath(row: at, section: 0)
        let task = taskList.remove(at: at)
        storage.delete(task: task)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [unowned self] _ in
                addNewTask()
            }
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editTask(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            self?.remove(indexPath.row)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
}
