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
    var listImages: [ListImagesDTO] = []
    var pageIndex: Int = 1
    
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
    
    
    //MARK: Binding Data
    func getObject(index: Int) -> ListImagesDTO? {
        if index < self.listImages.count {
            return self.listImages[index]
        }
        return nil
    }
    
    
}
