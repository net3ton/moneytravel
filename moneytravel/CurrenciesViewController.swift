//
//  CurrenciesViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 23/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

var appCurrencies: [CurrencyInfo] = [CurrencyInfo]()

struct CurrencyInfo {
    var iso: String
    var name: String
}

func appInitCurrencyInfos() {
    if !appCurrencies.isEmpty {
        return
    }
    
    //print(NSLocale.isoCurrencyCodes.count)
    //print(NSLocale.commonISOCurrencyCodes.count)

    for ciso in NSLocale.commonISOCurrencyCodes {
        let cname: String = NSLocale.current.localizedString(forCurrencyCode: ciso) ?? ""
        appCurrencies.append(CurrencyInfo(iso: ciso, name: cname))
    }
}



class CurrenciesViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    public var selectedHandler: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        appInitCurrencyInfos()
    }

    //override func didReceiveMemoryWarning() {
    //    super.didReceiveMemoryWarning()
    //}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appCurrencies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath)
        cell.textLabel?.text = appCurrencies[indexPath.row].iso
        cell.detailTextLabel?.text = appCurrencies[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        selectedHandler?(appCurrencies[indexPath.row].iso)
    }
    
    // MARK: - Search
    
    //func updateSearchResults(for searchController: UISearchController) {
    //    print(searchController.searchBar.text ?? "")
    //}
}
