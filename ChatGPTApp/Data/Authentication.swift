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
    @Published var authState: AuthState = .anonymous

    var googleAuth: GIDSignIn { get { GIDSignIn.sharedInstance } }
    var firebaseAuth: Auth { get { Auth.auth() } }
    
    func signIn() {
        if googleAuth.hasPreviousSignIn() {
            googleAuth.restorePreviousSignIn { [unowned self] user, error in
                withErrorCheck(user, error) {
                    authenticateUser(with: user!)
                }
            }
            return
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

        googleAuth.signIn(withPresenting: rootViewController) { [unowned self] result, error in
            withErrorCheck(result?.user, error) {
                authenticateUser(with: result!.user)
            }
        }
    }
    
    func signOut() {
        googleAuth.signOut()
        
        do {
            try firebaseAuth.signOut()
            
            self.authState = .anonymous
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

        firebaseAuth.signIn(with: credential) { [unowned self] (_, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.authState = .signedIn
            }
        }
    }

    private func withErrorCheck(_ user: GIDGoogleUser?, _ error: Error?, _ onSuccess: () -> Void) {
        if let error = error {
            print(error.localizedDescription)
            return
        }

        guard let user = user else {
            print("user is nil")
            return
        }
        
        onSuccess()
    }
}

