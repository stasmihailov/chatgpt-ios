//
//  Authentication.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 11/05/2023.
//

import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

enum AuthState {
    case anonymous
    case signedIn
}

class AppAuthentication: ObservableObject {
    @Published var user: GIDGoogleUser? = nil

    var googleAuth: GIDSignIn { get { GIDSignIn.sharedInstance } }
    var firebaseAuth: Auth { get { Auth.auth() } }
    
    func tryRestorePreviousSignIn() -> Bool {
        if googleAuth.hasPreviousSignIn() {
            googleAuth.restorePreviousSignIn { user, error in
                self.withErrorCheck(user, error) {
                    self.authenticateUser(with: user!)
                }
            }
            return true
        }
        return false
    }
    
    func signIn() {
        if tryRestorePreviousSignIn() {
            return
        }

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("clientID was nil")
            return
        }
        let configuration = GIDConfiguration(clientID: clientID)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

        googleAuth.configuration = configuration
        googleAuth.signIn(withPresenting: rootViewController) { result, error in
            self.withErrorCheck(result?.user, error) {
                self.authenticateUser(with: result!.user)
            }
        }
    }
    
    func signOut() {
        googleAuth.signOut()
        
        do {
            try firebaseAuth.signOut()
            
            self.user = nil
        } catch {
            print(error.localizedDescription)
        }
    }

    private func authenticateUser(with user: GIDGoogleUser) {
        guard let idToken = user.idToken else {
            print("user.idToken was nil")
            return
        }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken.tokenString,
            accessToken: user.accessToken.tokenString)

        firebaseAuth.signIn(with: credential) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let result = result else {
                print("result was nil")
                return
            }
            
            self.user = self.googleAuth.currentUser
        }
    }

    private func withErrorCheck(_ user: GIDGoogleUser?, _ error: Error?, _ onSuccess: () -> Void) {
        if let error = error {
            print(error.localizedDescription)
            return
        }

        guard user != nil else {
            print("user is nil")
            return
        }
        
        onSuccess()
    }
}

