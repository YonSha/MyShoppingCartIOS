//
//  RegisterVC.swift
//  BlackJackGame
//
//  Created by pc on 01/09/2019.
//  Copyright © 2019 yonsProject. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class RegisterVC: UIViewController {


    //properties:
    //textFields:
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var emailConfirmTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordConfirmTF: UITextField!
    
    
    //labels:
    @IBOutlet weak var passwordStrengthLabel: UILabel!
    
    
    
    //vars
    var emailEqual:Bool = false
    var passwordEqual:Bool = false
    
    
    var mRef:DatabaseReference!
    
    
    //tap var that recognize gestures -> target = self(AuthViewController), action ->
    // selector - > a func in authViewController - > dismissKeyboard(that ends the editing)
    // add the gesture to the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mRef = Database.database().reference()
        
        //tap var that recognize gestures -> target = self(AuthViewController), action ->
        // selector - > a func in authViewController - > dismissKeyboard(that ends the editing)
        // add the gesture to the view
        
        //  //tf return true enabled
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //tf return true enabled
        passwordTF.delegate = self
        passwordConfirmTF.delegate = self
        emailTF.delegate = self
        emailConfirmTF.delegate = self
    }
    
    //ends the editing (toggle the keyboard off)
    @objc func dismissKeyboard () {
        
        view.endEditing(true)
    }
    
    
    
    
    //register btn - > checks if the emails and passwords are equal and stand for the criterias req,
    // if so -> login and send the user to the main page,
    // if not -> error msg
    //Utilities class alert function
    //checks if the email already in the data base -> if so alert, if not -> create new user
    @IBAction func registerBtn(_ sender: UIButton) {
        

        //checks if the email already in use:
        mRef.child("Users").observe(DataEventType.value, with: { (snapShot) in
            
            for snap in snapShot.children {
                
                let uID = snap as! DataSnapshot
                
                
                self.mRef.child("Users").child(uID.key).child("userDetails").observe(DataEventType.value, with: { (snapShot) in
                    
                    
                    let dict = snapShot.value as! Dictionary<String,Any>
                    
                   
                    
                    if (self.emailTF.text?.elementsEqual(dict["email"] as! String ?? ""))!   {
                        
                        
                        Utilities.init().showAlert(title: "Error", message: "Email Already In Use", vc: self)
                        
                    }else{
                        
             
                        
                        if(self.emailEqual == true && self.passwordEqual == true){
                            
                            
                            
                            
                            let fAuth = Auth.auth()
                            guard let email = self.emailTF.text else { return }
                            guard let password = self.passwordTF.text else {return}
                            
                            fAuth.createUser(withEmail: email , password: password) { (authDataResult, error) in
                                
                                fAuth.signIn(withEmail: email, password: password, completion: { (authDataResult, error) in
                                    
                                    var userDetails = [String:Any]()
                                    userDetails["email"] = Auth.auth().currentUser?.email
                                    userDetails["name"] = Auth.auth().currentUser?.displayName ?? "no_name_provided"
                                    userDetails["id"] = fAuth.currentUser?.uid
                                    userDetails["phone_number"] = Auth.auth().currentUser?.phoneNumber ?? "no_number_provided"
                                    
                            
                    self.mRef.child("Users").child(fAuth.currentUser!.uid).child("userDetails").setValue(userDetails)
                                    
                                   
                                    
                                    
                                    
                                    if let toMainViewControllerVC = self.storyboard?.instantiateViewController(withIdentifier: "settingsVC"){
                                        toMainViewControllerVC.modalPresentationStyle = .fullScreen
                                        
                                        self.present(toMainViewControllerVC, animated: true, completion: {
                                         
                                         
                                        })
                                        
                                    }
                                })
                            }
                        }else {
                            //Utilities class alert function:
                            Utilities.init().showAlert(title: "Wrong Input", message: "Please Check that your email and password meets the required criterias", vc: self)
                            
                        }
                        
                        
                        
                    }
                    
                    
                })
                
                
            }
        })
        
        
        
       
        
        
    }
    
    
    //back to login VC btn
    @IBAction func backToLoginBtn(_ sender: UIButton) {
        
        if let toLoginVC = storyboard?.instantiateViewController(withIdentifier: "authVC"){
            
            toLoginVC.modalPresentationStyle = .fullScreen
            self.present(toLoginVC, animated: true) {
                
            }
        }
    }
    
    
    
    //checks  if the emails match
    // if so green, else red text
    @IBAction func emailChange(_ sender: UITextField) {
        
        
        
        
        if emailConfirmTF.text == emailTF.text {
            
            emailTF.textColor = UIColor.green
            emailConfirmTF.textColor = UIColor.green
            emailEqual = true
            
        }else if emailTF.text!.count > 1 && emailConfirmTF.text!.count > 1 {
            emailTF.textColor = UIColor.red
            emailConfirmTF.textColor = UIColor.red
            
            
        }
        
        
        
    }
    
    
    
    
    //on password change listener
    // checks conditions to good req/good password
    // shows the user password strength status
    // if passes all conditions -> passwordEqual boolean = true
    @IBAction func passwordChange(_ sender: UITextField) {
        
        
        if passwordTF.text == passwordConfirmTF.text {
            
            
            
            passwordTF.textColor = UIColor.green
            passwordConfirmTF.textColor = UIColor.green
            
            if(passwordTF.text!.count >= 6 && passwordConfirmTF.text!.count >= 6 && passwordTF.text!.count < 8 && passwordConfirmTF.text!.count < 8 ){
                passwordStrengthLabel.text = "ok"
                passwordStrengthLabel.textColor = UIColor.yellow
                passwordEqual = true
                
            }else if (passwordTF.text!.count >= 10 && passwordConfirmTF.text!.count >= 10){
                
                passwordStrengthLabel.text = "Strong"
                passwordStrengthLabel.textColor = UIColor.green
                passwordEqual = true
                
            }else{
                
                passwordStrengthLabel.text = "Weak"
                passwordStrengthLabel.textColor = UIColor.red
                passwordEqual = false
            }
            
        }else {
            
            passwordTF.textColor = UIColor.red
            passwordConfirmTF.textColor = UIColor.red
            passwordStrengthLabel.text = "No Match"
            passwordStrengthLabel.textColor = UIColor.red
            passwordEqual = false
            
        }
        
        
        
        
        
        
        
    }
    
    
    
    //checks if a user is logged in -> if so continue to main VC
    //else -> send user to login VC
    func checkCurrentUser () {
        
        if(Auth.auth().currentUser  == nil){
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "authVC") {
                self.navigationController?.present(vc, animated: true, completion: nil)
                
            }
        }
        
    }
    
    
}






// extention to UITEXTFIELDDELEGATE -> makes the keyboard return button work
extension UIViewController: UITextFieldDelegate{
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}


//extention to RegisterViewController class
//extention to  text field
//changes the input in the text fields:
//emails and passwords to restrict num of characters and symbols inputed
extension RegisterVC{
    
    
    //extention to  text field:
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //max chars allowed ->
        //disable bug that the user cant delete a chars after hiting max chars
        var text = textField.text ?? ""
        let swiftRange = Range(range, in: text)!
        let newString = text.replacingCharacters(in: swiftRange, with: string)
        
        
        if(textField.accessibilityIdentifier == "email"){
            
            //allowed characters:
            let allowedCharsOne = "abcdefghijklmnopqrstuvwxyz"
            let allowedNumbers = "1234567890"
            let allowedSymbols = "@."
            
            //array of each letter in each allowed propertie:
            let allowedCharsArr = CharacterSet(charactersIn: allowedCharsOne.uppercased() + allowedCharsOne + allowedNumbers + allowedSymbols)
            
            //the entered text from the user:
            let enteredCharsByUser = CharacterSet(charactersIn: string)
            
            
            
            
            return allowedCharsArr.isSuperset(of: enteredCharsByUser) && newString.count <= 25
        }
        
        
        
        
        return newString.count <= 15
    }
    



}
