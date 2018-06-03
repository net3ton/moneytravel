//
//  CurrenciesViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 23/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

struct CurrencyInfo {
    var iso: String
    var name: String

    private static var available: [CurrencyInfo] = [CurrencyInfo]()

    public static func getAllCurrencies() -> [CurrencyInfo] {
        if !available.isEmpty {
            return available
        }

        //print(NSLocale.isoCurrencyCodes.count)
        //print(NSLocale.commonISOCurrencyCodes.count)

        for ciso in NSLocale.commonISOCurrencyCodes {
            let cname: String = NSLocale.current.localizedString(forCurrencyCode: ciso) ?? ""
            if ciso == "BYR" {
                available.append(CurrencyInfo(iso: "BYN", name: cname))
                continue
            }

            available.append(CurrencyInfo(iso: ciso, name: cname))
        }

        return available
    }
}


class CurrenciesViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    
    public var selectedHandler: ((String) -> Void)?
    private var currencies: [CurrencyInfo] = [CurrencyInfo]()

    override func viewDidLoad() {
        super.viewDidLoad()

        currencies = CurrencyInfo.getAllCurrencies()
        searchBar.delegate = self
    }

    //override func didReceiveMemoryWarning() {
    //    super.didReceiveMemoryWarning()
    //}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath)
        cell.textLabel?.text = currencies[indexPath.row].iso
        cell.detailTextLabel?.text = currencies[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        selectedHandler?(currencies[indexPath.row].iso)
    }
    
    // MARK: - Search

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let allCurrencies = CurrencyInfo.getAllCurrencies()

        if searchText.isEmpty {
            currencies = allCurrencies
        }
        else {
            currencies = allCurrencies.filter { (info) -> Bool in
                return info.iso.lowercased().range(of: searchText.lowercased()) != nil ||
                    info.name.lowercased().range(of: searchText.lowercased()) != nil
            }
        }

        tableView.reloadData()
    }
}
