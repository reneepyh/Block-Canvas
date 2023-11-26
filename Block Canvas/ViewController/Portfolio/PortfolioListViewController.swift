//
//  PortfolioListViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/17.
//

import Foundation
import UIKit
import Combine

class PortfolioListViewController: UIViewController {
    @IBOutlet weak var portfolioListTableView: UITableView!
    
    private let emptyView: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "Tap plus button to add wallet."
        label.textColor = .secondaryBlur
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
        }
        return view
    }()
    
    private var viewModel = PortfolioListViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.loadWallets()
        viewModel.balance.removeAll()
        viewModel.updateWalletBalances()
        setupNavTab()
    }
    
    private func setupBindings() {
        viewModel.$walletAddresses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.portfolioListTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$balance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.portfolioListTableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UI Functions
extension PortfolioListViewController {
    private func setupTableView() {
        portfolioListTableView.delegate = self
        portfolioListTableView.dataSource = self
        portfolioListTableView.backgroundColor = .primary
        portfolioListTableView.rowHeight = UITableView.automaticDimension
        portfolioListTableView.estimatedRowHeight = 200
    }
    
    private func setupUI() {
        view.backgroundColor = .primary
        navigationItem.backButtonTitle = ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: "plus.circle.fill")?.withTintColor(.secondary, renderingMode: .alwaysOriginal), target: self, action: #selector(addWallet))
        // 如不內建demo錢包，加入以下empty view
        //        view.addSubview(emptyView)
        //        emptyView.snp.makeConstraints { make in
        //            make.centerX.equalTo(view.snp.centerX)
        //            make.centerY.equalTo(view.snp.centerY)
        //        }
    }
    
    private func setupNavTab() {
        navigationController?.navigationBar.isHidden = false
        let navigationBar = self.navigationController?.navigationBar
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .primary
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.tertiary, NSAttributedString.Key.font: UIFont.main(ofSize: 28)]
        navigationBarAppearance.shadowColor = .clear
        navigationBar?.standardAppearance = navigationBarAppearance
        navigationBar?.scrollEdgeAppearance = navigationBarAppearance
        let navigationExtendHeight: UIEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        navigationController?.additionalSafeAreaInsets = navigationExtendHeight
        
        tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - Add wallet
extension PortfolioListViewController {
    @objc private func addWallet() {
        guard
            let addressInputVC = UIStoryboard.portfolio.instantiateViewController(
                withIdentifier: String(describing: AddressInputPageViewController.self)
            ) as? AddressInputPageViewController
        else {
            return
        }
        addressInputVC.modalPresentationStyle = .overFullScreen
        navigationController?.pushViewController(addressInputVC, animated: true)
    }
}

// MARK: - Table View
extension PortfolioListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.walletAddresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let walletCell = portfolioListTableView.dequeueReusableCell(withIdentifier: WalletListCell.reuseIdentifier, for: indexPath) as? WalletListCell else {
            fatalError("Cannot create wallet list cell.")
        }
        
        guard let address = viewModel.walletAddresses[indexPath.row]["address"] else {
            fatalError("Cannot find wallet address.")
        }
        walletCell.addressLabel.text = address
        walletCell.arrowImageView.image = UIImage(systemName: "chevron.forward")?.withTintColor(.secondary, renderingMode: .alwaysOriginal)
        walletCell.walletNameTextField.delegate = self
        walletCell.walletNameTextField.text = viewModel.walletAddresses[indexPath.row]["name"]
        walletCell.walletNameTextField.isUserInteractionEnabled = false
        if viewModel.balance.count != viewModel.walletAddresses.count {
            if address.hasPrefix("0x") {
                walletCell.balanceLabel.text = "-- ETH"
                walletCell.walletImageView.image = UIImage(named: "ethereum")
            } else {
                walletCell.balanceLabel.text = "-- XTZ"
                walletCell.walletImageView.image = UIImage(named: "tezos")
            }
        } else {
            if let balance = viewModel.balance[address] {
                if address.hasPrefix("0x") {
                    walletCell.balanceLabel.text = "\(balance) ETH"
                    walletCell.walletImageView.image = UIImage(named: "ethereum")
                } else {
                    walletCell.balanceLabel.text = "\(balance) XTZ"
                    walletCell.walletImageView.image = UIImage(named: "tezos")
                }
            }
        }
        print(viewModel.walletAddresses[indexPath.row])
        
        return walletCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPortfolio" {
            let portfolioVC = segue.destination as? PortfolioDisplayViewController
            portfolioVC?.walletAddress = sender as? String
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPortfolio", sender: viewModel.walletAddresses[indexPath.row]["address"])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "") { [weak self] (action, view, completionHandler) in
            self?.viewModel.deleteWallet(at: indexPath.row)
            self?.portfolioListTableView.deleteRows(at: [indexPath], with: .left)
            // 如不內建demo錢包，加入以下empty view
            // emptyView.isHidden = !viewModel.walletAddresses.isEmpty
        }
        delete.backgroundColor = .systemPink
        delete.image = UIImage(systemName: "trash")
        
        let modify = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completionHandler) in
            completionHandler(true)
            if let walletListCell = self?.portfolioListTableView.cellForRow(at: indexPath) as? WalletListCell {
                walletListCell.walletNameTextField.isUserInteractionEnabled = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    walletListCell.walletNameTextField.becomeFirstResponder()
                }
            }
        }
        modify.backgroundColor = .secondaryBlur
        modify.image = UIImage(systemName: "pencil")
        
        let swipe = UISwipeActionsConfiguration(actions: [delete, modify])
        swipe.performsFirstActionWithFullSwipe = false
        return swipe
    }
}

// MARK: - UITextFieldDelegate
extension PortfolioListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let newName = textField.text, let walletListCell = textField.superview?.superview as? WalletListCell, let indexPath = portfolioListTableView.indexPath(for: walletListCell) {
            viewModel.updateWalletName(at: indexPath.row, newName: newName)
        }
        textField.resignFirstResponder()
        textField.isUserInteractionEnabled = false
        return true
    }
}
