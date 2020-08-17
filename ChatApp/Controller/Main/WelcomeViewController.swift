//
//  ViewController.swift
//  ChatApp
//
//  Created by Dan on 7/21/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    //outlet
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func setupUI() {
        loginButton.setRadiusSetting()
        signUpButton.setBorderSetting()
    }
    
    //MARK: IBAction
    @IBAction func loginButtonDidTapped(_ sender: Any) {
        self.push(storyBoard: Strings.mainView, type: LoginViewController.self) { (vc) in
        }
    }
    
    @IBAction func signUpButtonDidTapped(_ sender: Any) {
        self.push(storyBoard: Strings.mainView, type: SignUpViewController.self) { (vc) in
        }
    }

}


