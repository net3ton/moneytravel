//
//  Extensions.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 16/09/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import Foundation

public enum ESaveLocation {
    case documents
    case icloud
}

extension Data {
    private func getSharedPath() -> URL? {
        return FileManager().urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    public func saveTo(_ location: ESaveLocation, withName name: String) -> Bool {
        guard let path = (location == .icloud) ? appICloudDrive.getDocumentsPath() : getSharedPath() else {
            return false
        }
        
        do {
            let exportPath = path.appendingPathComponent(name)
            try write(to: exportPath)
        }
        catch let error {
            print("Failed to save data! ERROR: " + error.localizedDescription)
            return false
        }
        
        return true
    }
}

extension String {
    public func loc() -> String {
        return NSLocalizedString(self, tableName: "Localizable", value: "**\(self)**", comment: "")
    }
}
