//
//  MenuViewController.swift
//  InternetShop
//
//  Created by Алексей Колыченков on 18.04.2023.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol MenuDisplayLogic: AnyObject {
    func displayData(viewModel: Menu.Model.ViewModel.ViewModelData)
}

class MenuViewController: UIViewController, MenuDisplayLogic {
    // MARK: - Properties
    private lazy var menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(BannerTableViewCell.self, forCellReuseIdentifier: BannerTableViewCell.identifier)
        tableView.register(CategoryTableViewHeader.self, forHeaderFooterViewReuseIdentifier: CategoryTableViewHeader.identifier)
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGray6
        return tableView
    }()

    var interactor: MenuBusinessLogic?
    var router: (NSObjectProtocol & MenuRoutingLogic & MenuDataPassing)?

    let currentCategory: Category = .all
    let menuCell = MenuCell()

    private var activityIndicator: UIActivityIndicatorView?
    private var menuViewModel = MenuViewModel(cells: [])  ///Модель данных menu
    private let header = CategoryTableViewHeader()


  // MARK: Setup
    private func setup() {
        let viewController        = self
        let interactor            = MenuInteractor()
        let presenter             = MenuPresenter()
        let router                = MenuRouter()
        viewController.interactor = interactor
        viewController.router     = router
        interactor.presenter      = presenter
        presenter.viewController  = viewController
        router.viewController     = viewController
        router.dataStore          = interactor
    }
  
  // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        view.addSubview(menuTableView)
        activityIndicator = showActivityIndicator(in: view)
        setupConstraints()
        setupNavigationBar()
        interactor?.makeRequest(request: Menu.Model.Request.RequestType.getMenu)
    }

    // MARK: - Method
    func displayData(viewModel: Menu.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayMenu(menuViewModel: let menuViewModel):
            self.menuViewModel = menuViewModel
            activityIndicator?.stopAnimating()
            menuTableView.reloadData()
        }
    }

    private func showActivityIndicator(in view: UIView) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .lightGray
        activityIndicator.startAnimating()
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        return activityIndicator
    }

    // MARK: - Main View Setup
    private func setupNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .systemGray6
        let title = UIBarButtonItem(title: "London")
        let image = UIBarButtonItem(title: "", image: UIImage(systemName: "chevron.down"), target: self, action: #selector(switchCity))
        navigationItem.leftBarButtonItems = [title, image]
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.tintColor = .black
    }

    @objc func switchCity() {
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            menuTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            menuTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            menuTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            menuTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
// MARK: - UITableViewDelegate UITableViewDataSource
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        default: return menuViewModel.cells.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: BannerTableViewCell.identifier, for: indexPath)
            return cell
        default:
            let cellViewModel = menuViewModel.cells[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier, for: indexPath)
            guard let cell = cell as? MenuCell else { return UITableViewCell() }
            cell.set(viewModel: cellViewModel)
            if indexPath.item == 0, indexPath.row == 0 {
                cell.layer.cornerRadius = 36
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0: return nil
        default:
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CategoryTableViewHeader.identifier)
            return headerView
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0
        default: return 50
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 100
        default: return menuViewModel.cells[indexPath.row].height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            tableView.deselectRow(at: indexPath, animated: false)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
            router?.routeToItemDetails(value: indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .zero
    }
}
