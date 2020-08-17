//
//  SignUpViewController.swift
//  ChatApp
//
//  Created by Dan on 7/21/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Firebase

class SignUpViewController: UIViewController {
    //MARK: IBOutlet
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setImageTapped()
    }
    
    func setupUI() {
        signUpButton.setRadiusSetting()
        signInLabel.setMutltiText(a: Strings.LoginViewController.textSignIn1, b: Strings.LoginViewController.textSignIn2 )
        fullNameTextField.setupLeftImage(imageName: Strings.LoginViewController.user)
        emailAddressTextField.setupLeftImage(imageName: Strings.LoginViewController.email)
        passWordTextField.setupLeftImage(imageName: Strings.LoginViewController.password)
        signInTapped()
        fullNameTextField.delegate = self
        emailAddressTextField.delegate = self
        passWordTextField.delegate = self
        passWordTextField.returnKeyType = .done
    }
    
    func signInTapped() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.signInFunction(sender:)))
        signInLabel.isUserInteractionEnabled = true
        signInLabel.addGestureRecognizer(tap)
    }
    
    @objc func signInFunction(sender: UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setImageTapped() {
        avatarImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        avatarImage.addGestureRecognizer(tapGesture)
    }
    
    @objc func imageTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    //MARK: IBActions
    func signUpAndPostData() {
        guard let imageSelected = self.image else {
            ProgressHUD.showError("Please choose avatar!")
            return
        }
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else { return }
        guard let email = emailAddressTextField.text, let password = passWordTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let authData = authDataResult {
                let timestamp : Double = NSDate().timeIntervalSince1970 as Double
                let uid = authData.user.uid
                guard let email = authData.user.email, let name = self.fullNameTextField.text else { return }
                let storageProfileRef = FirebaseStorages.storageRef.child(authData.user.uid)
                //upload image storage
                let metaData = StorageMetadata()
                metaData.contentType = Strings.contentType
                storageProfileRef.putData(imageData, metadata: metaData) { (storageMetaData, error) in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                        return
                    }
                    storageProfileRef.downloadURL { (url, error) in
                        guard let metaImageUrl = url?.absoluteString else { return }
                        let users = User(id: uid, name: name, email: email, profileImage: metaImageUrl, timestamp: timestamp, isOnline: true)
                        guard let dict = try? DictionaryEncoder().encode(users) else { return }
                        Firestores.documentUser.document(authData.user.uid).setData(dict) { err in
                            if let err = err {
                                print("Error: \(err)")
                            } else {
                                ProgressHUD.showSucceed("Sign up success!", interaction: true)
                                let vc = MessagesViewController()
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func signUpButtonDidTapped(_ sender: Any) {
        ProgressHUD.show()
        signUpAndPostData()
    }
    
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = imageSelected
            avatarImage.image = imageSelected
        }
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            avatarImage.image = imageOriginal
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if ((fullNameTextField.text != "") && (emailAddressTextField?.text != "") && (passWordTextField?.text != "")) {
            signUpButton.isEnabled = true
            signUpButton.alpha = 1.0
        }
        if ((fullNameTextField.text == "") && (emailAddressTextField.text == "") && (passWordTextField.text == "")){
            signUpButton.isEnabled = false
            signUpButton.alpha = 0.5
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
}
