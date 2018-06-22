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
    private let service = GTLRSheetsService()
    private var uiroot: UIViewController?

    public func start() {
        GIDSignIn.sharedInstance().clientID = "188641982599-e2n205trq0s07tg5g29pbk2anfk365q7.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        //GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
        GIDSignIn.sharedInstance().signInSilently()
    }

    public func handle(url: URL!, sourceApplication: String!, annotation: Any!) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }

    public func signIn(vc: UIViewController) {
        uiroot = vc
        GIDSignIn.sharedInstance().signIn()
    }

    public func signOut() {
        GIDSignIn.sharedInstance().signOut()
    }

    public func isLogined() -> Bool {
        return service.authorizer != nil
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Failed to Google sign in! ERROR: " + error.localizedDescription)
            return
        }

        print("Google sign in ok.")
        service.authorizer = user.authentication.fetcherAuthorizer()
        
        // Perform any operations on signed in user here.
        /*
         let userId = user.userID                  // For client-side use only!
         let idToken = user.authentication.idToken // Safe to send to the server
         let fullName = user.profile.name
         let givenName = user.profile.givenName
         let familyName = user.profile.familyName
         let email = user.profile.email
         */
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Failed to Google sign out! ERROR: " + error.localizedDescription)
            return
        }

        print("Google sign out ok.")
        service.authorizer = nil
    }

    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        uiroot?.present(viewController, animated: true)
    }

    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true)
    }
}
