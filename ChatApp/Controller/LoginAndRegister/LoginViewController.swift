//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Dan on 7/21/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit
import FirebaseAuth
import ProgressHUD
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseDatabase

class LoginViewController: UIViewController{
    //MARK: IBOutlet
    @IBOutlet weak var facebookLogInButton: UIButton!
    @IBOutlet weak var googleLogInButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    var messageController : MessagesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func setupUI() {
        facebookLogInButton.setRadiusSetting()
        googleLogInButton.setRadiusSetting()
        logInButton.setRadiusSetting()
        logInButton.setTitle(Strings.LoginViewController.signIn, for: .normal)
        signUpLabel.setMutltiText(a:Strings.LoginViewController.textSignUp1, b:Strings.LoginViewController.textSignUp2)
        emailAddressTextField.setupLeftImage(imageName:Strings.LoginViewController.email)
        passWordTextField.setupLeftImage(imageName:Strings.LoginViewController.password)
        signUpTapped()
        emailAddressTextField.delegate = self
        passWordTextField.delegate = self
        passWordTextField.returnKeyType = .done
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    //MARK: IBAction
    
    @IBAction func signInButtonDidTapped(_ sender: Any) {
        guard let email = self.emailAddressTextField.text, let pasword = self.passWordTextField.text else { return }
        ProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: pasword) { [weak self] (authDataResult, error) in
            guard let self = self else { return }
            if error != nil {
                if !email.isValidEmail() || !pasword.isValidPassword() {
                    ProgressHUD.showError("Invalid email or password")
                }
                return
            }
            if let authData = authDataResult, Auth.auth().currentUser?.uid == authData.user.uid  {
                Firestores.documentUser.document(authData.user.uid).updateData(["isOnline": true])
                let vc = MessagesViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func googleSignInPressed(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func facebookSignInPressed(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            guard let accessToken = AccessToken.current else { return }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { [weak self] (user, error) in
                guard let self = self else { return }
                if let error = error {
                    print(error.localizedDescription)
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                if let userResult = user {
                    guard let imageURL = userResult.user.photoURL, let email = userResult.user.email, let name = userResult.user.displayName else { return }
                    let timestamp : Double = NSDate().timeIntervalSince1970 as Double
                    let users = User(id: userResult.user.uid, name: name, email: email, profileImage: imageURL.absoluteString, timestamp: timestamp, isOnline: true)
                    if let dict = try? DictionaryEncoder().encode(users) {
                        Firestores.documentUser.document(userResult.user.uid).setData(dict)
                    }
                    let vc = MessagesViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }
    }
    
    func signUpTapped() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.signUpFunction))
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(tap)
    }
    
    @objc func signUpFunction(sender: UITapGestureRecognizer) {
        self.push(storyBoard: Strings.mainView, type: SignUpViewController.self) { (vc) in
        }
    }
    
}

extension LoginViewController: GIDSignInDelegate {
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential, completion: { (authResult,error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            if let authData = authResult {
                guard let imageURL = authData.user.photoURL, let email = authData.user.email, let fullName = user.profile.name else { return }
                let timestamp : Double = NSDate().timeIntervalSince1970 as Double
                let users = User(id: authData.user.uid, name: fullName, email: email, profileImage: imageURL.absoluteString, timestamp: timestamp, isOnline: true)
                if let dict = try! DictionaryEncoder().encode(users) {
                    Firestores.documentUser.document(authData.user.uid).setData(dict)
                }
                let vc = MessagesViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let auth = user.authentication else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        Auth.auth().signIn(with: credentials) { (authResult, error) in
        }
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if ((emailAddressTextField?.text != "") && (passWordTextField?.text != "")) {
            logInButton.isEnabled = true
            logInButton.alpha = 1.0
        }
        if ((emailAddressTextField.text == "") && (passWordTextField.text == "")){
            logInButton.isEnabled = false
            logInButton.alpha = 0.5
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}
