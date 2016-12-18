//
//  PPi18n.swift
//  PPi18n
//
//  Created by wangpeng on 2016/11/17.
//  Copyright © 2016年 wangpeng. All rights reserved.
//

import UIKit

private let PPLanguageCellID = "PPLanguageCellID"

class PPLanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Language".i18n
        
        view.backgroundColor = UIColor.white
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.register(UITableViewCell.self, forCellReuseIdentifier: PPLanguageCellID)
        tableView!.tableFooterView = UIView(frame: .zero)
        view = tableView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ppLanguageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLanguageCellID, for: indexPath)
        cell.textLabel?.text = ppLanguageArray[indexPath.row].language
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView!.selectRow(at: PPLanguageTool.standard.selectedIndex, animated: false, scrollPosition: UITableViewScrollPosition.none)
        tableView!.cellForRow(at: PPLanguageTool.standard.selectedIndex)!.selectionStyle = .none
        tableView!.cellForRow(at: PPLanguageTool.standard.selectedIndex)!.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        tableView.visibleCells[indexPath.row].selectionStyle = .none
        tableView.visibleCells[indexPath.row].accessoryType = .checkmark
        PPLanguageTool.standard.setNewLanguage(newLanguage: ppLanguageArray[indexPath.row].languageCode)
    }
}

struct PPLanguage {
    var language: String
    var languageCode: String
}
fileprivate let ppLanguage_English = PPLanguage(language: "English", languageCode: "en")
fileprivate let ppLanguage_Chinese = PPLanguage(language: "中文", languageCode: "zh-Hans")
let ppLanguageArray = [ppLanguage_English, ppLanguage_Chinese]

fileprivate let ppLanguageCodeArray = ["en", "zh-Hans"]

class PPLanguageTool {
    
    static let standard = PPLanguageTool()
    private init() { initLanguage() }
    
    private var language: String?
    private var bundle: Bundle?
    
    var selectedIndex: IndexPath { return IndexPath(row: ppLanguageCodeArray.index(of: language!)!, section: 0) }
    
    // 加载语言
    func loadUserLanguage() {
        initLanguage()
        loadBundle()
        setNewLanguage(newLanguage: language!)
    }
    
    // 初始化语言
    private func initLanguage() {
        language = (UserDefaults.standard.value(forKey: "ppUserlanguage") as? String)?.languageCode
        if language != nil {} else {
            // 如果没有设置,则设置为系统语言
            language = UserDefaults.standard.stringArray(forKey: "AppleLanguages")![0].languageCode
            UserDefaults.standard.setValue(language! as String, forKey: "ppUserlanguage")
        }
    }
    
    // 加载 bundle
    private func loadBundle() {
        let path = Bundle.main.path(forResource: language!.languageCode, ofType: "lproj")
        bundle = Bundle(path: path!)
    }
    
    // 返回 table 中指定的 key 的值
    fileprivate func string(key: String, table: String = "Localizable") -> String {
        if bundle != nil { return NSLocalizedString(key, tableName: table, bundle: bundle!, value: "", comment: "") }
        return NSLocalizedString(key, comment: "")
    }
    
    // 设置语言
    func setNewLanguage(newLanguage: String) {
        if newLanguage == language { return }
        if ppLanguageCodeArray.contains(newLanguage) {
            let path = Bundle.main.path(forResource: newLanguage, ofType: "lproj")
            bundle = Bundle(path: path!)
            language = newLanguage
            UserDefaults.standard.setValue(language! as String, forKey: "ppUserlanguage")
            resetRootViewController()
        }
    }
    
    // 重置
    private func resetRootViewController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = MainViewController()
    }
}

extension String {
        
    var i18n: String { return PPLanguageTool.standard.string(key: self) }
    
    var languageCode: String {
        if self.contains("zh-Han") { return "zh-Hans" }
        if self.contains("en-") { return "en" }
        return self
    }
}
