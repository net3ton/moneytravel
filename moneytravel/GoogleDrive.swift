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

class GoogleDrive: NSObject, GIDSignInDelegate, GIDSignInUIDelegate {
    private let sheetsService = GTLRSheetsService()
    private let driveService = GTLRDriveService()
    private var uiroot: UIViewController?
    private var authCompletion: (() -> Void)?

    public func start() {
        GIDSignIn.sharedInstance().clientID = "188641982599-e2n205trq0s07tg5g29pbk2anfk365q7.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeSheetsDrive]
        GIDSignIn.sharedInstance().signInSilently()
    }

    public func handle(url: URL!, sourceApplication: String!, annotation: Any!) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }

    public func signIn(vc: UIViewController, completion: @escaping (() -> Void)) {
        uiroot = vc
        authCompletion = completion

        GIDSignIn.sharedInstance().signIn()
    }

    public func signOut(completion: @escaping (() -> Void)) {
        authCompletion = completion

        GIDSignIn.sharedInstance().disconnect()
    }

    public func isLogined() -> Bool {
        return GIDSignIn.sharedInstance().hasAuthInKeychain()
    }

    public func downloadFromRoot(filename: String, completion: @escaping ((Data?) -> Void)) {
        let querySearch = GTLRDriveQuery_FilesList.query()
        querySearch.q = String.init(format: "name = '%@' and 'root' in parents", filename)
        querySearch.spaces = "drive"
        querySearch.fields = "nextPageToken, files(id, name)"

        driveService.executeQuery(querySearch) { (ticket, result, error) -> Void in
            if error != nil {
                print("[Google Drive] Failed to find file! Error: " + error!.localizedDescription)
                completion(nil)
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
                print("[Google Drive] Failed to find file!")
                completion(nil)
                return
            }

            let queryGet = GTLRDriveQuery_FilesGet.query(withFileId: fileId)

            self.driveService.executeQuery(queryGet) { (ticket, result, error) -> Void in
                if error != nil {
                    print("[Google Drive] Failed to download file! Error: " + error!.localizedDescription)
                    completion(nil)
                    return
                }

                if let file = result as? GTLRDataObject {
                    print("File size = " + String(file.data.count))
                    completion(file.data)
                    return
                }

                print("[Google Drive] Failed to download file!")
                completion(nil)
            }
        }
    }

    public func uploadToRoot(data: Data, filename: String) {
        
    }
    
    /*
    public func uploadPhoto(image: UIImage) {
        let file = GTLRDrive_File()
        file.name = "some name"
        file.descriptionProperty = "Uploaded from Google Drive IOS"
        file.mimeType = "image/png"

        let data = UIImagePNGRepresentation(image)

        let uploadParameters = GTLRUploadParameters(data: data!, mimeType: file.mimeType!)
        uploadParameters.shouldUploadWithSingleRequest = true

        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)
        query.fields = "id"
        //let waitIndicator = self.showWaitIndicator("Uploading To Google Drive")
        
        driveService.executeQuery(query) { (ticket, insertedFile, error) -> Void in
            let myFile = insertedFile as? GTLDriveFile
            //waitIndicator.dismissWithClickedButtonIndex(0, animated: true)
            if error == nil {
                println("File ID \(myFile?.identifier)")
            } else {
                println("An Error Occurred! \(error)")
            }
            
        }
    }
    */
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("[Google Drive] Failed to sign in! ERROR: " + error.localizedDescription)
            return
        }

        print("[Google Drive] sign in")
        sheetsService.authorizer = user.authentication.fetcherAuthorizer()
        driveService.authorizer = user.authentication.fetcherAuthorizer()

        //let userId = user.userID                  // For client-side use only!
        //let idToken = user.authentication.idToken // Safe to send to the server
        //let fullName = user.profile.name
        //let givenName = user.profile.givenName
        //let familyName = user.profile.familyName
        //let email = user.profile.email

        authCompletion?()
        authCompletion = nil
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("[Google Drive] Failed to sign out! ERROR: " + error.localizedDescription)
            return
        }

        print("[Google Drive] sign out")
        sheetsService.authorizer = nil
        driveService.authorizer = nil

        authCompletion?()
        authCompletion = nil
    }

    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        uiroot?.present(viewController, animated: true)
    }

    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true)
    }
}
