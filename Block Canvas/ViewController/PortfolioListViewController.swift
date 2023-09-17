//
//  PortfolioListViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/17.
//

import UIKit

class PortfolioListViewController: UIViewController {

    @IBOutlet weak var portfolioListTableView: UITableView!
    
    private let userDefaults = UserDefaults.standard
    
    private var ethWallets: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        portfolioListTableView.delegate = self
        portfolioListTableView.dataSource = self
        portfolioListTableView.rowHeight = UITableView.automaticDimension
        portfolioListTableView.estimatedRowHeight = 200
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addWallet))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        findEthWallets()
    }
    
    private func findEthWallets() {
        ethWallets = userDefaults.object(forKey: "ethWallets") as? [String] ?? []
        if ethWallets.count == 0 {
            guard
                let addressInputVC = UIStoryboard.portfolio.instantiateViewController(
                    withIdentifier: String(describing: AddressInputPageViewController.self)
                ) as? AddressInputPageViewController
            else {
                return
            }
            addressInputVC.modalPresentationStyle = .overFullScreen
            navigationController?.pushViewController(addressInputVC, animated: false)
            addressInputVC.navigationItem.hidesBackButton = true
        } else {
            portfolioListTableView.reloadData()
        }
    }

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

extension PortfolioListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ethWallets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let walletCell = portfolioListTableView.dequeueReusableCell(withIdentifier: WalletListCell.reuseIdentifier, for: indexPath) as? WalletListCell else {
            fatalError("Cannot create wallet list cell.")
        }
        walletCell.addressLabel.text = ethWallets[indexPath.row]
        print(ethWallets[indexPath.row])
        
        return walletCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPortfolio" {
            let portfolioVC = segue.destination as? PortfolioDisplayViewController
            portfolioVC?.ethAddress = sender as? String
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPortfolio", sender: ethWallets[indexPath.row])
    }
}
