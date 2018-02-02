//
//  CategoryViewController.swift
//  taskapp
//
//  Created by Fumitaka Hijino on 2018/01/30.
//  Copyright © 2018年 Fumitaka Hijino. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UIViewController {

    var category: Category!
    let realm = try! Realm()
    
    @IBOutlet weak var categoryName: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        self.categoryName.text = category.categoryName
        
        if category.categoryName == "" {
            try! realm.write {
                self.realm.add(self.category, update: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // 遷移する際に、画面が非表示になるとき呼ばれるメソッド
    override func viewWillDisappear(_ animated: Bool) {
        
        // カテゴリ名を空欄（nil）にした場合、そのカテゴリを削除する
        if self.categoryName.text! == "" {
            
                // データベースから削除する
                try! realm.write {
                    self.realm.delete(self.category)
                }
            
        }
        // カテゴリ名が入力されている場合、そのカテゴリ名で新規登録/更新
        else {
            try! realm.write {
                self.category.categoryName = self.categoryName.text!
                self.realm.add(self.category, update: true)
            }
        }
        super.viewWillDisappear(animated)
    }
    

    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
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
