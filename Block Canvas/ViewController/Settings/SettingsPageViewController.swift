//
//  SettingsPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/30.
//

import UIKit

class SettingsPageViewController: UIViewController {
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        view.backgroundColor = .primary
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupNavTab()
    }
}

// MARK: - UI Functions
extension SettingsPageViewController {
    private func setupTableView() {
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        settingsTableView.backgroundColor = .primary
        settingsTableView.isScrollEnabled = false
        settingsTableView.rowHeight = 60
    }
    
    private func setupNavTab() {
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
        navigationItem.backButtonTitle = ""
        
        tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - Table View
extension SettingsPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let settingsCell = settingsTableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseIdentifier, for: indexPath) as? SettingsCell else {
            fatalError("Cannot create settings cell.")
        }
        settingsCell.selectionStyle = .none
        
        if indexPath.row == 0 {
            settingsCell.iconImageView.image = UIImage(systemName: "heart.fill")?.withTintColor(.secondary, renderingMode: .alwaysOriginal)
            settingsCell.settingsLabel.text = "Watchlist"
            return settingsCell
        } else if indexPath.row == 1 {
            settingsCell.iconImageView.image = UIImage(systemName: "eye.slash.fill")?.withTintColor(.secondary, renderingMode: .alwaysOriginal)
            settingsCell.settingsLabel.text = "Hidden"
            return settingsCell
        } else {
            settingsCell.iconImageView.image = UIImage(systemName: "apps.iphone")?.withTintColor(.secondary, renderingMode: .alwaysOriginal)
            settingsCell.settingsLabel.text = "Widget"
            return settingsCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard
                let watchlistVC = UIStoryboard.settings.instantiateViewController(
                    withIdentifier: String(describing: WatchlistPageViewController.self)
                ) as? WatchlistPageViewController
            else {
                return
            }
            watchlistVC.modalPresentationStyle = .overFullScreen
            navigationController?.pushViewController(watchlistVC, animated: true)
        } else if indexPath.row == 1 {
            guard
                let hiddenVC = UIStoryboard.settings.instantiateViewController(
                    withIdentifier: String(describing: HiddenPageViewController.self)
                ) as? HiddenPageViewController
            else {
                return
            }
            hiddenVC.modalPresentationStyle = .overFullScreen
            navigationController?.pushViewController(hiddenVC, animated: true)
        } else if indexPath.row == 2 {
            guard
                let widgetVC = UIStoryboard.settings.instantiateViewController(
                    withIdentifier: String(describing: WidgetPageViewController.self)
                ) as? WidgetPageViewController
            else {
                return
            }
            widgetVC.modalPresentationStyle = .overFullScreen
            navigationController?.pushViewController(widgetVC, animated: true)
        }
    }
}
