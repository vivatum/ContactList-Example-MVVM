//
//  ListTableViewController.swift
//  ContactListExample
//
//  Created by Vivatum on 15/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Contacts

final class ListTableViewController: UITableViewController {

    private var detailViewController: DetailViewController? = nil
    
    private var updateButton: UIBarButtonItem!
    private var showFavoritedButton: UIBarButtonItem!
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let navTitle = "Contacts"
    private var noDataView: NoDataView?
    
    private var selectFavoritedOnly: Bool = false
    
    let dataSource = ContactDataSource()
    
    lazy var viewModel: ContactListViewModel = {
        return ContactListViewModel(dataSource: dataSource)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViewModel()
        self.setupNavElements()
        self.setupTableView()
        self.updateContactCollection()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    
    // MARK: - Setup View
    
    private func setupNavElements() {
        self.title = navTitle
        self.setupNavigationButtons()
        self.setupRefreshControl()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        self.noDataView = NoDataView()
        tableView.dataSource = self.dataSource
        tableView.backgroundView = self.noDataView
        tableView.tableFooterView = UIView()
    }
    
    
    // MARK: - Setup ViewModel
    
    private func setupViewModel() {
        
        self.dataSource.data.bindAndFire { [weak self] data in
            DispatchQueue.main.async {
                self?.updtateNoDataMessage(data)
                self?.tableView.reloadData()
            }
        }
        
        self.viewModel.onErrorHandling = { [weak self] error in
            DDLogError("Error: \(String(describing: error?.localizedDescription))")
            
            DispatchQueue.main.async {
                self?.hideAllProgressActivities()
                
                if let err = error {
                    DDLogError("ActionError content: \(err)")
                    AlertManager.showErrorAlert(err.alertContent)
                }
                
                if let viewData = self?.dataSource.data.value {
                    self?.updtateNoDataMessage(viewData)
                }
            }
        }
        
        self.viewModel.stopProgress = { [weak self] in
            DDLogInfo("Hide progress elements")            
            self?.hideAllProgressActivities()
        }
        
        self.viewModel.showContactDetails = { [weak self] contact in
            DDLogInfo("Show contact details")
            self?.hideAllProgressActivities()
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "showDetail", sender: contact)
            }
        }
    }
    
    
    // MARK: - Progress Activities
    
    private func setupRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(updateContactCollection), for: .valueChanged)
    }
    
    private func showTitleProgress() {
        DispatchQueue.main.async {
            self.navigationItem.titleView = self.activityIndicator
            self.activityIndicator.startAnimating()
        }
    }
    
    private func hideTitleProgress() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.navigationItem.titleView = nil
            self.title = self.navTitle
        }
    }
    
    private func hideAllProgressActivities() {
        DispatchQueue.main.async() {
            self.updateButton.isEnabled = true
            self.showFavoritedButton.isEnabled = true
            self.refreshControl?.perform(#selector(UIRefreshControl.endRefreshing), with: nil, afterDelay: 0)
            self.hideTitleProgress()
        }
    }
    
    
    // MARK: - Navigation Buttons
    
    private func setupNavigationButtons() {
        self.setupUpdateButton()
        self.setupFavoriteButton()
    }
    
    private func setupUpdateButton() {
        DispatchQueue.main.async {
            self.updateButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.updateContactCollection))
            self.navigationItem.setLeftBarButton(self.updateButton, animated: true)
        }
    }
    
    private func setupFavoriteButton() {
       DispatchQueue.main.async {
            let buttonIcon: UIImage? = self.selectFavoritedOnly ? UIImage(named: "starFavorited") : UIImage(named: "star")
            self.showFavoritedButton = UIBarButtonItem(image: buttonIcon, style: .plain, target: self, action: #selector(self.favoritesAction))
            self.navigationItem.setRightBarButton(self.showFavoritedButton, animated: true)
        }
    }
    
    
    // MARK: - NoDataView Message
    
    private func updtateNoDataMessage(_ viewData: TableViewData) {
        self.noDataView?.message = viewData.content.isEmpty ? (self.viewModel.selectFavorites ? .noFavorites : .noDataFetched) : .noMessage
    }
    
    
    // MARK: - Actions
    
    @objc func updateContactCollection() {
        DDLogInfo("Start updating Contact collection")
        DispatchQueue.main.async() {
            self.updateButton.isEnabled = false
            self.showFavoritedButton.isEnabled = false
            self.showTitleProgress()
            self.refreshControl?.beginRefreshing()
        }
        self.viewModel.updateContacts()
    }
    
    @objc func favoritesAction() {
        DDLogInfo("Favorites action pressed...")
        self.selectFavoritedOnly.toggle()
        self.setupFavoriteButton()
        self.viewModel.selectFavorites = self.selectFavoritedOnly
    }
    

    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            self.viewModel.selectedIndexPath = indexPath
            self.updateButton.isEnabled = false
            self.showFavoritedButton.isEnabled = false
            self.showTitleProgress()
        }
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            
            guard let selectedContact = sender as? CNContact else {
                DDLogError("Can't get CNContact from sender")
                return
            }
            
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.selectedContact = selectedContact
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            detailViewController = controller
        }
    }
}
