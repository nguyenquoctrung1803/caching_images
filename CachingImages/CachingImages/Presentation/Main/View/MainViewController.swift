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

class LoadingView: UIView {
    
    private var activityIndicatorView: UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .white
        view.startAnimating()
        view.center = self.center
        return view
    }
    
    private var isPresenting: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black.withAlphaComponent(0.5)
        self.alpha = 0.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func present() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(self)
        fadeIn()
    }
    
    func dismiss() {
        guard isPresenting == true else { return }
        fadeOut()
    }
    
    private func fadeIn() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            self.alpha = 0.5
        }) { (bool: Bool) in
            self.addSubview(self.activityIndicatorView)
            self.isPresenting = true
        }
    }
    
    private func fadeOut() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            self.alpha = 0.0
        }) { (bool: Bool) in
            self.removeFromSuperview()
            self.isPresenting = false
        }
    }
}

