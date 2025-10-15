//
//  ListImagesViewController.swift
//  CachingImages
//
//  Created by trungnguyenq on 10/14/25.
//

import UIKit

class ListImagesViewController: MainViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    //MARK: - Variables
    private let viewModel: ListImagesViewModel = ListImagesViewModel()
    
    private var debounceTimer: Timer?
    private let debounceInterval: TimeInterval = 2.0 // 2s debounce
    
    private let allowedSpecialCharacters = "!@#$%^&*():.\""
    private let maxCharacterLimit = 15
    
    
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
        self.textField.delegate = self
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
        self.viewModel.pullToReresh()
    }
    
    // MARK: - Debounce Handler
    private func handleTextFieldChange(_ text: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.performSearch(text: text)
        }
    }
    
    private func performSearch(text: String) {
        self.viewModel.applySearch(keySearch: text)
    }
    
    // MARK: - Text Validation
    private func isValidCharacter(_ character: Character) -> Bool {
        let characterString = String(character)
        
        // Check if it's an emoji
        if characterString.containsEmoji {
            return false
        }
        
        // Check if it's a letter (A-Z, a-z, no accents)
        if characterString.rangeOfCharacter(from: CharacterSet.letters) != nil {
            // Check if it contains diacritics (accented characters)
            let normalized = characterString.folding(options: .diacriticInsensitive, locale: .current)
            if normalized != characterString {
                return false // Contains diacritics
            }
            return true
        }
        
        // Check if it's a digit (0-9)
        if characterString.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
            return true
        }
        
        // Check if it's a whitespace
        if characterString == " " {
            return true
        }
        
        // Check if it's an allowed special character
        if allowedSpecialCharacters.contains(character) {
            return true
        }
        
        return false
    }
}

extension ListImagesViewController: ListImagesViewModelDelegate {
    func showErrorMessages(_text: String) {
        let alertController = UIAlertController(title: "Error", message: _text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Code to execute when OK is tapped
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func endRefreshing() {
        if let baseRefreshControl = self.baseRefreshControl {
            baseRefreshControl.endRefreshing()
        }
        self.tableView.reloadData()
    }
    
    func showLoading() {
        self.showLoadingIcon()
    }
    
    func hideLoading() {
        self.hideLoadingIcon()
    }
}

extension ListImagesViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get current text
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else {
            return false
        }
        
        // Get new text
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        // Check limit
        if updatedText.count > maxCharacterLimit {
            return false
        }
        
        //Empty is clear search
        if string.isEmpty {
            handleTextFieldChange(updatedText)
            return true
        }
        
        // Validate characters
        for character in string {
            if !isValidCharacter(character) {
                return false
            }
        }
        
        // Debounce Search with 2s
        handleTextFieldChange(updatedText)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = self.textField.text {
            self.handleTextFieldChange(text)
        }
        return true
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
        return self.viewModel.getListObjects().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Prevent Crashing
        if indexPath.row >= self.viewModel.getListObjects().count {
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
    
    
    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        // UITableView only moves in one direction, y axis
//        let currentOffset = scrollView.contentOffset.y
//        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
//
//        if maximumOffset - currentOffset <= 12.0 + 8.0 {
//            self.viewModel.loadMoreImages()
//        }
//    }
    
    // MARK: - Load More
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = self.viewModel.getListObjects().count - 1
        
        // Trigger load more in 3rd last item
        if indexPath.row >= lastItem - 2 {
            self.viewModel.loadMoreImages()
        }
    }
}
// MARK: - String Extension for Emoji Detection
extension String {
    var containsEmoji: Bool {
        return unicodeScalars.contains { $0.isEmoji }
    }
}
extension UnicodeScalar {
    var isEmoji: Bool {
        switch value {
        case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x1F1E6...0x1F1FF, // Regional country flags
            0x2600...0x26FF,   // Misc symbols
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
            127000...127600, // Various asian characters
            65024...65039, // Variation selector
            9100...9300, // Misc items
            8400...8447: // Combining Diacritical Marks for Symbols
            return true
            
        default: return false
        }
    }
}
