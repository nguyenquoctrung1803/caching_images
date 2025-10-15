//
//  ListImagesViewModel.swift
//  CachingImages
//
//  Created by trungnguyenq on 10/14/25.
//

import Foundation

protocol ListImagesViewModelDelegate {
    func reloadTableView()
    func endRefreshing()
    func showLoading()
    func hideLoading()
    func showErrorMessages(_text: String)
}

class ListImagesViewModel {
    //MARK: Repositories
    private let repositories: ListImagesRepositories = ListImagesRepositories()
    
    var delegate: ListImagesViewModelDelegate?
    
    //MARK: - Custom Queue
    private let dataQueue = DispatchQueue(label: "com.trung.nguyenq.CachingImages.loadingImages", qos: .userInitiated, attributes: .concurrent)
    
    //MARK: - Variables
    private var listImages: [ListImagesDTO] = []
    var pageIndex: Int = 1
    var limit: Int = 100
    var keySearch: String?
    
    var canLoadMore: Bool = true
    var isLoadingLoadMore: Bool = false
    
    private func reloadTableView() {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.reloadTableView()
            }
        }
    }
    
    private func endRefreshing() {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.endRefreshing()
            }
        }
    }
    
    private func showLoading() {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.showLoading()
            }
        }
    }
    
    private func hideLoading() {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.hideLoading()
            }
        }
    }
    
    private func showErrorMessages(msg: String) {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.showErrorMessages(_text: msg)
            }
        }
    }
    
    
    //MARK: Get Data
    func getListImages() {
        self.showLoading()
        dataQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.repositories.getListImages(page: self.pageIndex, limit: self.limit) { [weak self] values, error in
                guard let self = self else { return }
                
                if let error = error {
                    //Handle Logic Error Code In Here
                    self.showErrorMessages(msg: error.localizedDescription)
                }
                
                if let values = values {
                    self.listImages = values
                }else{
                    self.listImages.removeAll()
                }
                
                if self.listImages.count < self.limit {
                    self.canLoadMore = false
                }
                
                self.reloadTableView()
                self.hideLoading()
            }
        }
    }
    
    func pullToReresh() {
        self.showLoading()
        
        self.pageIndex = 1
        self.canLoadMore = true
        
        dataQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.repositories.getListImages(page: self.pageIndex) { [weak self] values, error in
                guard let self = self else { return }
                
                if let error = error {
                    //Handle Logic Error Code In Here
                    print(error)
                    self.showErrorMessages(msg: error.localizedDescription)
                }
                
                if let values = values {
                    self.listImages = values
                }else{
                    self.listImages.removeAll()
                }
                
                if self.listImages.count < self.limit {
                    self.canLoadMore = false
                }
                
                self.endRefreshing()
                self.hideLoading()
            }
        }
    }
    
    // MARK: - Load More
    func loadMoreImages() {
        if !canLoadMore {
            return
        }
        
        if self.isLoadingLoadMore {
            return
        }
        
        self.showLoading()
        self.isLoadingLoadMore = true
        pageIndex += 1
        
        dataQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.repositories.getListImages(page: self.pageIndex) { [weak self] values, error in
                guard let self = self else { return }
                
                self.isLoadingLoadMore = false
                
                if let values = values {
                    if let error = error {
                        //Handle Logic Error Code In Here
                        self.showErrorMessages(msg: error.localizedDescription)
                        self.pageIndex -= 1
                        return
                    }
                    
                    if !values.isEmpty {
                        self.listImages.append(contentsOf: values)
                        self.reloadTableView()
                    } else {
                        self.pageIndex -= 1
                    }
                    
                    if values.count < self.limit {
                        self.canLoadMore = false
                    }
                    
                    self.hideLoading()
                }
            }
        }
    }
    
    func getListObjects() -> [ListImagesDTO] {
        if let keySearch = self.keySearch {
            return self.listImages.filter({ $0.author.lowercased().contains(keySearch.lowercased()) || $0.id.lowercased().contains(keySearch.lowercased()) })
        }
        return self.listImages
    }
    
    //MARK: Utitliti
    func applySearch(keySearch: String) {
        if keySearch.isEmpty {
            self.keySearch = nil
        }else{
            self.keySearch = keySearch
        }
        self.reloadTableView()
    }
    
    
    //MARK: Binding Data
    func getObject(index: Int) -> ListImagesDTO? {
        if index < self.getListObjects().count {
            return self.getListObjects()[index]
        }
        return nil
    }
    
    
    
    
}
