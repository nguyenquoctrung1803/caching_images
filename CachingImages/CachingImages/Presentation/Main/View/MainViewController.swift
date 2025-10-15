//
//  ViewController.swift
//  CachingImages
//
//  Created by trungnguyenq on 10/14/25.
//

import UIKit

class MainViewController: UIViewController {
    
    var baseRefreshControl: UIRefreshControl?
    
    private var loadingView: LoadingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView = LoadingView(frame: self.view.frame)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK: Utitilites
    func addPullToRefreshControl(toTableView: UITableView) {
        toTableView.refreshControl = nil
        self.baseRefreshControl = UIRefreshControl()
        toTableView.refreshControl = self.baseRefreshControl
        self.baseRefreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func customInitTableView(_ tableView: UITableView) {
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 12))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 12))
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
    }
    
    
    func showLoadingIcon() {
        self.loadingView?.present()
    }
    
    
    func hideLoadingIcon() {
        self.loadingView?.dismiss()
    }
}
