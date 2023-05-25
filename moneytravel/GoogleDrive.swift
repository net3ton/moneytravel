//
//  googleDrive.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 21/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

let appGoogleDrive = GoogleDrive()

enum EGoogleDriveError {
    case none
    case notFoundError
    case downloadError
    case lookupError
}

enum EGoogleDriveMimeType: String {
    case binary = "application/x-binary"
    case csv = "text/csv"
}

class GoogleDrive: NSObject {
    private let sheetsService = GTLRSheetsService()
    private let driveService = GTLRDriveService()
    public var authHandler: ((Bool) -> Void)?

    public func start() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            self.didSignInFor(user: user, withError: error)
        }
    }

    public func handle(url: URL) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    public func signIn(vc: UIViewController) {
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { signInResult, error in
            
            if let error = error {
                print("[Google Drive] Failed to sign in! ERROR: " + error.localizedDescription)
                return
            }

            guard let user = signInResult?.user else {
                print("[Google Drive] Failed to sign in! No valid user returned!")
                return
            }
            
            let additionalScopes = [kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeSheetsDrive]
            
            if let grantedScopes = user.grantedScopes {
                if additionalScopes.allSatisfy(grantedScopes.contains) {
                    self.didSignInFor(user: user, withError: error)
                    return
                }
            }

            user.addScopes(additionalScopes, presenting: vc) { signInResult, error in
                self.didSignInFor(user: signInResult?.user, withError: error)
            }
        }
    }

    public func signOut() {
        GIDSignIn.sharedInstance.disconnect { error in
            self.didDisconnectWith(error: error)
        }
    }

    public func isSignedIn() -> Bool {
        return GIDSignIn.sharedInstance.currentUser != nil
    }
    
    public func lookupInRoot(filename: String, completion: @escaping ((String?, String?, EGoogleDriveError) -> Void)) {
        let querySearch = GTLRDriveQuery_FilesList.query()
        querySearch.q = String.init(format: "name = '%@' and 'root' in parents", filename)
        querySearch.spaces = "drive"
        querySearch.fields = "nextPageToken, files(id, name, properties)"

        driveService.executeQuery(querySearch) { (ticket, result, error) -> Void in
            if error != nil {
                print("[Google Drive] Failed to find file! Error: " + error!.localizedDescription)
                completion(nil, nil, .lookupError)
                return
            }
            
            if let filesList = result as? GTLRDrive_FileList {
                if let files = filesList.files {
                    if !files.isEmpty {
                        if let fileId = files[0].identifier {
                            let fileHash = files[0].properties?.additionalProperty(forName: "hash") as? String ?? ""
                            print("[Google Drive] File id: " + fileId)
                            print("[Google Drive] File hash: " + fileHash)
                            completion(fileId, fileHash, .none)
                            return
                        }
                    }
                }
            }
            
            print("[Google Drive] File not found!")
            completion(nil, nil, .notFoundError)
        }
    }
    
    public func downloadFile(fileid: String?, completion: @escaping ((Data?, EGoogleDriveError) -> Void)) {
        guard let fileId = fileid else {
            completion(nil, .notFoundError)
            return
        }
        
        let queryGet = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)
        
        driveService.executeQuery(queryGet) { (ticket, result, error) -> Void in
            if error != nil {
                print("[Google Drive] Failed to download file! Error: " + error!.localizedDescription)
                completion(nil, .downloadError)
                return
            }
            
            if let file = result as? GTLRDataObject {
                print("[Google Drive] File size: " + String(file.data.count))
                completion(file.data, .none)
                return
            }
            
            print("[Google Drive] Failed to download file!")
            completion(nil, .downloadError)
        }
    }
    
    /*
    public func downloadFromRoot(filename: String, completion: @escaping ((Data?, String?, EGoogleDriveError) -> Void)) {
        let querySearch = GTLRDriveQuery_FilesList.query()
        querySearch.q = String.init(format: "name = '%@' and 'root' in parents", filename)
        querySearch.spaces = "drive"
        querySearch.fields = "nextPageToken, files(id, name)"

        driveService.executeQuery(querySearch) { (ticket, result, error) -> Void in
            if error != nil {
                print("[Google Drive] Failed to find file! Error: " + error!.localizedDescription)
                completion(nil, nil, .lookupError)
                return
            }

            var fileId: String = ""
            if let filesList = result as? GTLRDrive_FileList {
                if let files = filesList.files {
                    if !files.isEmpty {
                        fileId = files[0].identifier ?? ""
                        print("[Google Drive] File id: " + fileId)
                    }
                }
            }

            if fileId.isEmpty {
                print("[Google Drive] File not found!")
                completion(nil, nil, .notFoundError)
                return
            }

            let queryGet = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)

            self.driveService.executeQuery(queryGet) { (ticket, result, error) -> Void in
                if error != nil {
                    print("[Google Drive] Failed to download file! Error: " + error!.localizedDescription)
                    completion(nil, fileId, .downloadError)
                    return
                }

                if let file = result as? GTLRDataObject {
                    print("[Google Drive] File size: " + String(file.data.count))
                    completion(file.data, fileId, .none)
                    return
                }

                print("[Google Drive] Failed to download file!")
                completion(nil, fileId, .downloadError)
            }
        }
    }
    */

    public func uploadToRoot(data: Data, filename: String, filehash: String? = nil, description: String? = nil, mime: EGoogleDriveMimeType, completion: @escaping ((Bool) -> Void)) {
        let file = GTLRDrive_File()
        file.name = filename
        file.descriptionProperty = description
        file.mimeType = mime.rawValue

        if let fileHash = filehash {
            file.properties = GTLRDrive_File_Properties()
            file.properties?.setAdditionalProperty(fileHash, forName: "hash")
        }

        let uploadParameters = GTLRUploadParameters(data: data, mimeType: file.mimeType!)
        uploadParameters.shouldUploadWithSingleRequest = true

        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)

        driveService.executeQuery(query) { (ticket, insertedFile, error) -> Void in
            if let error = error {
                print("[Google Drive] Failed to upload file! Error: " + error.localizedDescription)
                completion(false)
                return
            }

            print("[Google Drive] File uploaded: " + String(data.count))
            completion(true)
        }
    }

    public func updateFile(data: Data, fileid: String, filehash: String? = nil, mime: EGoogleDriveMimeType, completion: @escaping ((Bool) -> Void)) {
        let uploadParameters = GTLRUploadParameters(data: data, mimeType: mime.rawValue)
        uploadParameters.shouldUploadWithSingleRequest = true

        let file = GTLRDrive_File()
        
        if let fileHash = filehash {
            file.properties = GTLRDrive_File_Properties()
            file.properties?.setAdditionalProperty(fileHash, forName: "hash")
        }
        
        let query = GTLRDriveQuery_FilesUpdate.query(withObject: file, fileId: fileid, uploadParameters: uploadParameters)
        
        driveService.executeQuery(query) { (ticket, result, error) -> Void in
            if let error = error {
                print("[Google Drive] Failed to update file! Error: " + error.localizedDescription)
                completion(false)
                return
            }

            print("[Google Drive] File updated: " + String(data.count))
            completion(true)
        }
    }

    public func makeSpreadsheet(name: String, history: [DaySpends], completion: @escaping ((Bool) -> Void)) {
        let sheetProps = GTLRSheets_SpreadsheetProperties()
        sheetProps.title = name

        let sheet = GTLRSheets_Spreadsheet()
        sheet.properties = sheetProps

        let query = GTLRSheetsQuery_SpreadsheetsCreate.query(withObject: sheet)
        sheetsService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("[Google Spreadsheets] Failed to create spreadsheet! Error: " + error.localizedDescription)
                completion(false)
                return
            }

            let sheet = result as! GTLRSheets_Spreadsheet
            let id = sheet.spreadsheetId
            
            // cells
            let googleSheet = GoogleSheet()
            googleSheet.appendRow(bgcolor: UIColor.white)
            googleSheet.addString("Date/Time", align: .center)
            googleSheet.addString("Sum", align: .center)
            googleSheet.addString("Currency", align: .center)
            googleSheet.addString(appSettings.currencyBase, align: .center)
            googleSheet.addString("Category", align: .center)
            googleSheet.addString("Comment", align: .center)
            
            var sumFormula = ""
            
            for info in history {
                if info.spends.isEmpty {
                    continue
                }

                googleSheet.appendRow(bgcolor: COLOR_SPEND_HEADER)
                
                let cellOne = gs_cell_address(column: 3, row: googleSheet.getCurrentRow() + 1)
                let cellTwo = gs_cell_address(column: 3, row: googleSheet.getCurrentRow() + info.spends.count)
                
                googleSheet.addDate(info.date)
                googleSheet.addEmpty(count: 2)
                googleSheet.addFormula(String(format: "=SUM(%@:%@)", cellOne, cellTwo))
                googleSheet.addEmpty(count: 2)
                googleSheet.setBordersAll(top: .dashed)

                if !sumFormula.isEmpty {
                    sumFormula += ","
                }
                sumFormula += gs_cell_address(column: 3, row: googleSheet.getCurrentRow())
                
                for (ind, spend) in info.spends.enumerated() {
                    googleSheet.appendRow(bgcolor: (ind % 2 == 1) ? COLOR_SPEND1 : COLOR_SPEND2)
                    googleSheet.addTime(spend.date!)
                    googleSheet.addFloat(spend.sum)
                    googleSheet.addString(spend.currency!)
                    googleSheet.addFloat(spend.bsum)
                    googleSheet.addString(spend.category!.name!)
                    googleSheet.addString(spend.comment ?? "")
                }
            }

            googleSheet.appendRow(bgcolor: UIColor.white)

            googleSheet.appendRow(bgcolor: COLOR_CAT)
            googleSheet.addEmpty(count: 3)
            googleSheet.addFormula(String(format: "=SUM(%@)", sumFormula))
            googleSheet.addEmpty(count: 2)
            googleSheet.setBordersAll(top: .solid)
            
            // properties
            let gridProps = GTLRSheets_GridProperties()
            gridProps.frozenRowCount = 1
            
            let sheetProps = GTLRSheets_SheetProperties()
            sheetProps.gridProperties = gridProps
            sheetProps.title = "MoneyTravel"
            
            let reqProps = GTLRSheets_UpdateSheetPropertiesRequest()
            reqProps.properties = sheetProps
            reqProps.fields = "gridProperties.frozenRowCount"

            // batch
            let batchCells = GTLRSheets_Request()
            batchCells.updateCells = googleSheet.getUpdateCellsRequest()
            
            let batchProps = GTLRSheets_Request()
            batchProps.updateSheetProperties = reqProps

            let requestBatch = GTLRSheets_BatchUpdateSpreadsheetRequest()
            requestBatch.requests = []
            requestBatch.requests?.append(batchCells)
            requestBatch.requests?.append(batchProps)
            
            let queryBatch = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: requestBatch, spreadsheetId: id!)
            self.sheetsService.executeQuery(queryBatch) { (ticket, result, error) in
                if let error = error {
                    print("[Google Spreadsheets] Failed to update spreadsheet! Error: " + error.localizedDescription)
                    completion(false)
                    return
                }
                
                print("[Google Spreadsheets] export complete.")
                completion(true)
            }
        }
    }

    func didSignInFor(user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("[Google Drive] Failed to sign in! ERROR: " + error.localizedDescription)
            return
        }
        
        guard user != nil else {
            print("[Google Drive] Failed to sign in! No valid user returned!")
            return
        }
        
        print("[Google Drive] sign in")
        
        if let grantedScopes = user.grantedScopes {
            if grantedScopes.contains(kGTLRAuthScopeSheetsSpreadsheets) {
                sheetsService.authorizer = user.fetcherAuthorizer
            }
            else {
                print("[Google Drive] No granted scope for Spreadsheets!")
            }
            
            if grantedScopes.contains(kGTLRAuthScopeSheetsDrive) {
                driveService.authorizer = user.fetcherAuthorizer
            }
            else {
                print("[Google Drive] No granted scope for Drive!")
            }
        }

        authHandler?(true)
    }

    func didDisconnectWith(error: Error!) {
        if let error = error {
            print("[Google Drive] Failed to sign out! ERROR: " + error.localizedDescription)
            return
        }

        print("[Google Drive] sign out")
        sheetsService.authorizer = nil
        driveService.authorizer = nil

        authHandler?(false)
    }
    
    public func isDriveEnabled() -> Bool {
        return driveService.authorizer != nil
    }
    
    public func isSpreadsheetsEnabled() -> Bool {
        return sheetsService.authorizer != nil
    }
}
