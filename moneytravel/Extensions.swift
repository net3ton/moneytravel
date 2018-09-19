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
    case temp
}

public func get_shared_path() -> URL? {
    return FileManager().urls(for: .documentDirectory, in: .userDomainMask).first
}

public func get_temp_path() -> URL? {
    return FileManager().temporaryDirectory
}

extension Data {
    private func getPath(_ location: ESaveLocation) -> URL? {
        switch location {
        case .icloud:
            return appICloudDrive.getDocumentsPath()
        case .documents:
            return get_shared_path()
        case .temp:
            return get_temp_path()
        }
        
        //return nil
    }
    
    public func saveTo(_ location: ESaveLocation, withName name: String) -> Bool {
        guard let path = getPath(location) else {
            return false
        }
        
        let exportPath = path.appendingPathComponent(name)
        return saveTo(exportPath)
    }
    
    public func saveTo(_ path: URL) -> Bool {
        do {
            try write(to: path)
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
