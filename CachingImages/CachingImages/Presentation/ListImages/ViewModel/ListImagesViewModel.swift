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
}

class ListImagesViewModel {
    //MARK: Repositories
    private let repositories: ListImagesRepositories = ListImagesRepositories()
    
    var delegate: ListImagesViewModelDelegate?
    
    //MARK: - Variables
    private var listImages: [ListImagesDTO] = []
    var pageIndex: Int = 1
    var keySearch: String?
    
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
                delegate.reloadTableView()
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
    
    
    //MARK: Get Data
    func getListImages() {
        self.repositories.getListImages(page: self.pageIndex) { values, error in
            if let error = error {
                //Handle Logic Error Code In Here
                print(error)
            }
            
            if let values = values {
                self.listImages = values
                self.reloadTableView()
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
