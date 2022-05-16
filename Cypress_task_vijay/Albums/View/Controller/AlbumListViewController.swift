//
//  ViewController.swift
//  Cypress_Interview_Task_Vijay
//
//  Created by Vijay on 13/05/22.
//

import UIKit

class AlbumListViewController: UIViewController {

    @IBOutlet weak var albumsTableView: UITableView!
    
    lazy var viewModel = {
        AlbumListViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
        initViewModel()

    }
    override func viewDidLayoutSubviews() {
        initView()
        initViewModel()
    }
    
    func initView()
    {
        albumsTableView.delegate = self
        albumsTableView.dataSource = self
        albumsTableView.layoutIfNeeded()
        albumsTableView.allowsSelection = false
        albumsTableView.separatorStyle = .none
        albumsTableView.showsVerticalScrollIndicator = false
    }
    
    func initViewModel()
    {
        viewModel.getAlbumList()
        viewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.albumsTableView.reloadData()
                self?.viewModel.scrollToRow(tableView: self!.albumsTableView)
            }
        }
    }
}

// MARK: - UITableViewDelegate\
extension AlbumListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
}

// MARK: - UITableViewDataSource
extension AlbumListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getAlbumListCellCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeue(AlbumTVCell.identifier, AlbumTVCell.self)
        let cellVM = viewModel.getAlbumCellViewModel(at: indexPath)
        cell.cellViewModel = cellVM
        return cell
    }
    
    
}
