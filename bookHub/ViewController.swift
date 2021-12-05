//
//  ViewController.swift
//  bookHub
//
//  Created by student on 10/2/21.
//

import UIKit

class ViewController: UIViewController, AccountCreatable {
    
    var userNamePassDictionary = ["admin": "admin", "test": "test", "register": "test", "register@test.com": "test"]
    
    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    
    func createAlert(title: String, msg: String) {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputEmail.layer.borderWidth = 1
        inputPassword.layer.borderWidth = 1
        inputEmail.layer.borderColor = UIColor.lightGray.cgColor
        inputPassword.layer.borderColor = UIColor.lightGray.cgColor
        inputEmail.layer.cornerRadius = 10.0
        inputPassword.layer.cornerRadius = 10.0
        
        configureItems()
    }
    
    @objc func navigateToDashboard(){
        if ((inputEmail.text ?? "").isEmpty) || ((inputPassword.text ?? "").isEmpty){
                    createAlert(title: "Missing Entry!", msg: "Missing username or password")
        } else {
            if userNamePassDictionary[inputEmail.text!] == inputPassword.text {
                Favorites.sharedInstance.isGuest = false
                performSegue(withIdentifier: "loginToDashboard", sender: self)
            } else {
                createAlert(title: "Invalid Entry!", msg: "Combination of username and password is invalid.Please give valid details")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginToRegistration" {
            let signUpSeg = segue.destination as! RegistrationViewController
            signUpSeg.delegate = self
        }
        if segue.identifier == "loginToDashboard" {
            Favorites.sharedInstance.favorites = []
            if !(Favorites.sharedInstance.isGuest) {
                let barViewControllers = segue.destination as! UITabBarController
                let nav = barViewControllers.viewControllers![0] as! UINavigationController
                let destinationViewController = nav.topViewController as! DashBoardTableViewController
                destinationViewController.username = self.inputEmail.text!
                
                Favorites.sharedInstance.username = self.inputEmail.text!
                Favorites.sharedInstance.isGuest = false
            }
            
        }
    }
    
    private func configureItems(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Login",
            style: .done,
            target: self,
            action: #selector(navigateToDashboard))
    }
    
    @IBAction func register(_ sender: Any) {
        performSegue(withIdentifier: "loginToRegistration", sender: self)
    }
    
    @IBAction func guestLogin(_ sender: Any) {
        Favorites.sharedInstance.isGuest = true
        performSegue(withIdentifier: "loginToDashboard", sender: self)
    }
    
    func addAccount(username: String, password: String) {
        userNamePassDictionary[username] = password
    }
}

