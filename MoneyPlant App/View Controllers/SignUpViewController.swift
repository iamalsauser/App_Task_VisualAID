//
//  SignUpViewController.swift
//  MoneyPlant App
//
//  Created by admin86 on 15/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var tenantSegCtrl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
        print(URL.documentsDirectory)
    }
    
    func setUpElements() {
        errorLabel.alpha = 0
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleHollowButton(signUpButton)
    }

    // Check the fields and validate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns the error message.
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        
        // Check if password is secure
        let cleanedPassword  = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false{
            // Password is not secure enough
            return "Password must contain at least 8 characters, including at least one uppercase letter, one lowercase letter, and one number."
        }
        
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
    
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            // There is something wrong with the fields, show error message
            showError(error!)
        }else {
            
            // Create cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            var tenant: String
            if tenantSegCtrl.selectedSegmentIndex == 0{
                tenant = "Tesla"
            }else{
                tenant = "TATA Corp"
            }
            
            
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) {(result, err) in
                // Check for errors
                if err != nil {
                    // There was an error creating the user
                    self.showError("Error creating user.")
                }else{
                    // User created successfully, now store the first name and last name
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["firstName": firstName, "lastName": lastName, "uid": result!.user.uid]) { (error) in
                        if error != nil{
                            // Show error message
                            self.showError("Error storing user data.")
                        }
                    }
                    // Transition to the Home Screen
                    
                    PersistenceController.shared.addUser(name: firstName, email: email, password: password, tenant: tenant)
                    print(URL.documentsDirectory)
                    self.transitionToHome()
                }
            }
        }
        
    }
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1.0
    }
    func transitionToHome() {
        let dashBaordVC = storyboard?.instantiateViewController(identifier: Constants.Storyboard.dashboardVCID) as? DashboardViewController
        
        view.window?.rootViewController = dashBaordVC
        view.window?.makeKeyAndVisible()
    }
    
}
