//
//  InputViewController.swift
//  taskapp
//
//  Created by Fumitaka Hijino on 2018/01/28.
//  Copyright © 2018年 Fumitaka Hijino. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var createCategory: UIButton!
    @IBOutlet weak var reviseCategory: UIButton!
    
    var task: Task!
    //var category: Category!
    let realm = try! Realm()
    
    // DB内のカテゴリが格納されるリスト。
    // 名前順でソート。昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.selectRow(task.category, inComponent: 0, animated: false)
        
    }

    // カテゴリ登録/編集ページに画面遷移する時にデータを渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let categoryViewController: CategoryViewController = segue.destination as! CategoryViewController
        
        if segue.identifier == "reviseCategorySegue" {
            let selectedRow = self.categoryPicker.selectedRow(inComponent: 0)
            categoryViewController.category = categoryArray[selectedRow]
        }
        else {
            let category = Category()
            
            let categoryArray = realm.objects(Category.self)
            if categoryArray.count != 0 {
                category.id = categoryArray.max(ofProperty: "id")! + 1
            }
            categoryViewController.category = category
            
        }
        
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
    
 
    
    
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    // 遷移する際に、画面が非表示になるとき呼ばれるメソッド
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            
            let categoryArray = realm.objects(Category.self)
            if categoryArray.count != 0 {
                let selectedRow = self.categoryPicker.selectedRow(inComponent: 0)
                self.task.category = categoryArray[selectedRow].id
            }
            
            
            self.realm.add(self.task, update: true)
        }
        
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    
    
    func setNotification(task: Task){
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "（タイトルなし）"
    }
        else {
            content.title = task.title
        }
        
        if task.contents == "" {
            content.body = "（タイトルなし）"
        }
        else {
            content.body = task.contents
        }
        
        content.sound = UNNotificationSound.default()
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) {
            (error) in
            print(error ?? "ローカル通知登録 OK") // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests {
            (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // カテゴリ入力画面から戻ってきた時に PickerView を更新する
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryPicker.reloadAllComponents()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
