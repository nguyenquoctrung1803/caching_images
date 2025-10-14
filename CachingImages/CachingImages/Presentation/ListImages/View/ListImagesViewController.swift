//
//  ListImagesViewController.swift
//  CachingImages
//
//  Created by trungnguyenq on 10/14/25.
//

import UIKit

class ListImagesViewController: MainViewController {

    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Variables
    private let viewModel: ListImagesViewModel = ListImagesViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.initLayout()
        self.initTableView()
    }
    
    func bindViewModel() {
        self.viewModel.delegate = self
        self.viewModel.getListImages()
    }
    
    func initLayout() {
        self.customInitTableView(self.tableView)
    }
    
    func initTableView() {
        self.addPullToRefreshControl(toTableView: self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.registerCell()
    }
    
    func registerCell() {
        self.tableView.register(UINib(nibName: kListImagesItemTableViewCell, bundle: nil), forCellReuseIdentifier: kListImagesItemTableViewCell)
    }
    
    // MARK: - Pull To Refresh
    override func pullToRefresh(_ sender: Any) {
        guard let refreshControl = sender as? UIRefreshControl else { return }
        refreshControl.beginRefreshing()
    }
}

extension ListImagesViewController: ListImagesViewModelDelegate {
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func endRefreshing() {
        if let baseRefreshControl = self.baseRefreshControl {
            baseRefreshControl.endRefreshing()
        }
    }
    
    func showLoading() {
        
    }
    
    func hideLoading() {
        
    }
}

extension ListImagesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.listImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Prevent Crashing
        if indexPath.row >= self.viewModel.listImages.count {
            return UITableViewCell()
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: kListImagesItemTableViewCell) as? ListImagesItemTableViewCell {
            cell.selectionStyle = .none
            if let obj = self.viewModel.getObject(index: indexPath.row) {
                cell.configure(obj: obj)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
