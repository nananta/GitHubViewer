//
//  PullRequestsVC.swift
//  GitHubViewer
//
//  Created by Nitinan Ananta on 11/14/18.
//  Copyright © 2018 Nitinan Ananta. All rights reserved.
//

import UIKit

class PullRequestsVC: UITableViewController
{

    private func setupTableView()
    {
        tableView.register(JournalTableViewCell.self, forCellReuseIdentifier: JournalTableViewCell.reuseId())
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.sectionHeaderHeight = tableView.frame.height * 0.2
        
        // Fill empty space
        tableView.tableFooterView = UIView()
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView?
    {
        let hdr = UIView()
//        hdr.backgroundColor = UILookAndFeel.colorTheme(ignoreWhite: true).withAlphaComponent(0.8)
        hdr.layer.cornerRadius = 5
        
        // Repo search bar
        let searchBar = UISearchBar()
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.barTintColor = .clear
//        searchBar.textField()?.tintColor = UILookAndFeel.colorTheme()
//        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        hdr.addSubview(searchBar)
        searchBar.
        searchBar.add(to: hdr, pin: msgLabel, option: .bottom)
        searchBar.setWidthHeightAnchors(equalTo: msgLabel, widthMultiplier: 1, heightMultiplier: 1)
        
        return hdr
    }

}

extension PullRequestsVC: UISearchBarDelegate
{
    
}
