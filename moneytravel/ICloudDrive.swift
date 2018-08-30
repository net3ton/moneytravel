//
//  CloudDrive.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 30/08/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

let appICloudDrive = ICloudDrive()

class ICloudDrive {
    public func isEnabled() -> Bool {
        return FileManager().ubiquityIdentityToken != nil
    }

    //public func getLocalPath() -> URL? {
    //    return FileManager().urls(for: .documentDirectory, in: .userDomainMask).first
    //}

    public func getDocumentsPath() -> URL? {
        guard let icloudUrl = FileManager().url(forUbiquityContainerIdentifier: nil) else {
            print("Failed to get iCloud path! ERROR:")
            return nil
        }
        
        let docsUrl = icloudUrl.appendingPathComponent("Documents")
        
        do {
            if (!FileManager().fileExists(atPath: docsUrl.path)) {
                try FileManager().createDirectory(at: docsUrl, withIntermediateDirectories: true, attributes: nil)
            }
        }
        catch let error {
            print("Failed to create Documents in iCloud! ERROR: " + error.localizedDescription)
            return nil
        }
        
        return docsUrl
    }
    
    public func loadFromFile(_ filename: String) -> Data? {
        guard let path = getDocumentsPath() else {
            return nil
        }
        
        do {
            return try Data(contentsOf: path.appendingPathComponent(filename))
        }
        catch let error {
            print("Failed load file from iCloud! ERROR: " + error.localizedDescription)
        }

        return nil
    }

    public func saveToFile(_ filename: String, data: Data) -> Bool {
        guard let path = getDocumentsPath() else {
            return false
        }

        do {
            try data.write(to: path.appendingPathComponent(filename))
        }
        catch let error {
            print("Failed save file to iCloud! ERROR: " + error.localizedDescription)
            return false
        }

        return true
    }
}
