//
//  ViewController.swift
//  MyToDoApp
//
//  Created by leejungchul on 2021/12/09.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var editBtn: UIBarButtonItem!
    
    var doneBtn: UIBarButtonItem?
    
    var tasks = [Task]() {
        didSet {
            self.saveTasks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnTap))
        tableView.dataSource = self
        tableView.delegate = self
        self.loadTasks()
        // Do any additional setup after loading the view.
    }
    
    @objc func doneBtnTap() {
        self.navigationItem.leftBarButtonItem = self.editBtn
        self.tableView.setEditing(false, animated: true)
    }

    @IBAction func tapEditBtn(_ sender: UIBarButtonItem) {
        guard !self.tasks.isEmpty else { return }
        self.navigationItem.leftBarButtonItem = self.doneBtn
        self.tableView.setEditing(true, animated: true)
    }
    
    @IBAction func tapAddBtn(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "할일 등록", message: nil, preferredStyle: .alert)
        let registerBtn = UIAlertAction(title: "등록", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text else {return}
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            self?.tableView.reloadData()
        }
        let cancelBtn = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(registerBtn)
        alert.addAction(cancelBtn)
        alert.addTextField { textfield in
            textfield.placeholder = "할일을 입력해 주세요"
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveTasks() {
        let data = self.tasks.map {
            [
                "title" : $0.title,
                "done" : $0.done
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(data, forKey: "tasks")
    }
    
    func loadTasks() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "tasks") as? [[String: Any]] else { return }
        self.tasks = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else { return nil }
            return Task(title: title, done: done)
        }
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let row = indexPath.row
        let task = self.tasks[row]
        
        cell.textLabel?.text = task.title
        
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row]
        task.done = !task.done
        self.tasks[indexPath.row] = task
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        debugPrint(self.tasks)
        if self.tasks.isEmpty {
            self.doneBtnTap()
        }
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var tasks = self.tasks
        let task = tasks[sourceIndexPath.row]
        tasks.remove(at: sourceIndexPath.row)
        tasks.insert(task, at: destinationIndexPath.row)
        self.tasks = tasks
    }
}
