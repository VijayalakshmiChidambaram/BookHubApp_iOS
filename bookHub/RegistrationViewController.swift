//
//  RegistrationViewController.swift
//  bookHub
//
//  Created by student on 10/3/21.
//

import UIKit

protocol AccountCreatable {
    func addAccount(username: String, password: String)
}

class RegistrationViewController: UIViewController {
    
    var delegate: AccountCreatable?
    
    @IBOutlet weak var registerEmail: UITextField!
    @IBOutlet weak var registerPassword: UITextField!
    @IBOutlet weak var registerConfirm: UITextField!
    
    func createAlert(title: String, msg: String) {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerEmail.layer.borderWidth = 1
        registerPassword.layer.borderWidth = 1
        registerConfirm.layer.borderWidth = 1
        registerEmail.layer.borderColor = UIColor.lightGray.cgColor
        registerConfirm.layer.borderColor = UIColor.lightGray.cgColor
        registerPassword.layer.borderColor = UIColor.lightGray.cgColor
        registerEmail.layer.cornerRadius = 10.0
        registerConfirm.layer.cornerRadius = 10.0
        registerPassword.layer.cornerRadius = 10.0
        
        configureItems()
    }
    
    @objc func navigateToDashboard(){
        if ((registerEmail.text ?? "").isEmpty) || ((registerPassword.text ?? "").isEmpty) || ((registerConfirm.text ?? "").isEmpty){
                    createAlert(title: "Missing Entry!", msg: "Missing username or password")
        } else {
            if registerPassword.text == registerConfirm.text {
                delegate?.addAccount(username: registerEmail.text!, password: registerPassword.text!)
                performSegue(withIdentifier: "registerToDashboard", sender: self)
            } else {
                createAlert(title: "Password Mismatch!", msg: "Password and Confirm Password does not match")
            }
        }
    }
    
    private func configureItems(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Sign Up",
            style: .done,
            target: self,
            action: #selector(navigateToDashboard))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registerToDashboard" {
            let barViewControllers = segue.destination as! UITabBarController
            let nav = barViewControllers.viewControllers![0] as! UINavigationController
            let destinationViewController = nav.topViewController as! DashBoardTableViewController
            destinationViewController.username = self.registerEmail.text!
            Favorites.sharedInstance.username = self.registerEmail.text!
            Favorites.sharedInstance.favorites = []
    
            let file = "\(Favorites.sharedInstance.username).txt"
            print("file name: " + file)
            let text = ""
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
                let fileURL = dir.appendingPathComponent(file)
                
                // creating favorites file
                do {
                    try text.write(to: fileURL, atomically: false, encoding: .utf8)
                } catch {
                    print("Error writing to file")
                }
            }
        }
    }
}
