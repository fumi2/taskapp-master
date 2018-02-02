//
//  ViewController.swift
//  taskapp
//
//  Created by Fumitaka Hijino on 2018/01/28.
//  Copyright © 2018年 Fumitaka Hijino. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryPickerForSearch: UIPickerView!
    
    
    
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
   // var selectedCategoryId:Int!
    
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
  
    
    //選択時の動作
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        if self.categoryArray.count != 0 {
            self.taskArray = self.realm.objects(Task.self).filter("category = %@", categoryArray[row].id).sorted(byKeyPath: "date", ascending: false)
            self.tableView.reloadData()
        }
        
    }
    
    
    // DB内のカテゴリが格納されるリスト。
    // 名前順でソート。昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
    
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        categoryPickerForSearch.dataSource = self
        categoryPickerForSearch.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController: InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }
        else {
            let task = Task()
            task.date = Date()
            
            let taskArray = realm.objects(Task.self)
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
        
    }
    
    // タスク入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        categoryPickerForSearch.reloadAllComponents()
    }
    
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
        
    }
    
    // MARK: UIPickerViewDataSourceプロトコルのメソッド
    // コンポーネントの数を返すメソッド
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // コンポーネントに含まれるデータの数（＝カテゴリの数）を返すメソッド
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    // MARK: UIPickerViewDelegateプロトコルのメソッド
    //データを返すメソッド
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArray[row].categoryName
    }
    
    
    
    
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil) // ←追加する
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return.delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
                
            }
        }
    }
    
 
    
    // 「全てのタスク」ボタンを押した時の動作
    @IBAction func allTaskButton(_ sender: Any) {
        self.taskArray = self.realm.objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        tableView.reloadData()
    }
    
}

