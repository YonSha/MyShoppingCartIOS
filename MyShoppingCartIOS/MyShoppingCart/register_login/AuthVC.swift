//
//  AuthVC.swift
//  BlackJackGame
//
//  Created by pc on 01/09/2019.
//  Copyright © 2019 yonsProject. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import Firebase
import FirebaseDatabase

class AuthVC: UIViewController {
    

    //properties:

    //outlets:
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!



    //vars:
    var fAuth = Auth.auth()
    var ref:DatabaseReference!
    var userID:String?

    //tap var that recognize gestures -> target = self(AuthViewController), action ->
    // selector - > a func in authViewController - > dismissKeyboard(that ends the editing)
    // add the gesture to the view

    //google gmail sign in -> more at AppDelegate
    //auto sign in after first sign in with gmail(premission granted)
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()

        // ...

        ref = Database.database().reference()

        userID = Auth.auth().currentUser?.uid

        //tap var that recognize gestures -> target = self(AuthViewController), action ->
        // selector - > a func in authViewController - > dismissKeyboard(that ends the editing)
        // add the gesture to the view
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AuthVC.dismissKeyboard))
        view.addGestureRecognizer(tap)

        emailTF.delegate = self
        passwordTF.delegate = self
        checkCurrentUser()

    }





    //ends the editing (toggle the keyboard off)
    @objc func dismissKeyboard () {

        view.endEditing(true)
    }


    //login func - >
    //minimum pass & email chars
    // login into firebase auth
    //Utilities class alert function:
    @IBAction func loginBtn(_ sender: UIButton) {

        //email and password from the TF's
        let email = emailTF.text!
        let password = passwordTF.text!

        //sign in to the database with an email and password if are avail in the databse auth:
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in


            if let err = error {
                print("error sign in" + err.localizedDescription)

                //Utilities class alert function:
                Utilities.init().showAlert(title: "Wrong Credentials", message: "Your Password/Email does not match", vc: self)


                return
            }else{

                self.checkCurrentUser()
            }
            print("Signed in: " + (authDataResult?.user.email)!)
        }

    }



    @IBAction func registerBtn(_ sender: UIButton) {


        if let toRegisterVC = storyboard?.instantiateViewController(withIdentifier: "registerVC"){
            
            toRegisterVC.modalPresentationStyle = .fullScreen
            
            self.present(toRegisterVC, animated: true) {

            }
        }


    }


    //reset the user password with firebase
    //opens an alert box that asks the user email;
    //after the user inputs his email and press "ok"
    //a reset password email is sent to his email address
    @IBAction func forgotPasswordBtn(_ sender: UIButton) {
        
        let forgotPasswordAlert = UIAlertController(title: "Reset Password", message: "Please enter your email to reset your password", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (resetEmailTF) in
            resetEmailTF.placeholder = "Email.."


            forgotPasswordAlert.addAction(UIAlertAction(title: "Reset my password", style: .default, handler: { (UIAlertAction) in

                self.fAuth.sendPasswordReset(withEmail: resetEmailTF.text ?? "", completion: { (error) in

                    if let err = error{
                        //Utils alert function
                        Utilities.init().showAlert(title: "Error", message: "No such email", vc: self)
                    }
                })

            }))

        }





        self.present(forgotPasswordAlert, animated: true, completion: nil)
    }




    //gmail login
    // auth listener, if user is logged in -> send to main VC
    @IBAction func gmailLoginBtn(_ sender: UIButton) {

        //google gmail sign in -> more at AppDelegate
        //auto sign in after first sign in with gmail(premission granted)
      
       GIDSignIn.sharedInstance().signIn()


        //auth state listener:
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                //if user signed in:
                //calls checkCurrentUser func -> checks if he signed or not, if signd
                // sends to main VC


                if(auth.currentUser != nil){
                    var userDetails = [String:Any]()
                    userDetails["email"] = Auth.auth().currentUser?.email
                    userDetails["name"] = Auth.auth().currentUser?.displayName ?? "no_name_provided"
                    userDetails["id"] = auth.currentUser?.uid
                    userDetails["phone_number"] = Auth.auth().currentUser?.phoneNumber ?? "no_number_provided"
                    
                    

                    self.ref.child("Users").child(auth.currentUser!.uid).child("userDetails").setValue(userDetails)

                    self.checkCurrentUser()
                }
            } else {
                // No User is signed in.
            }
        }



    }



    //checks if a user is logged in -> if so continue to main VC
    //else -> send user to login VC
    func checkCurrentUser () {

        if(Auth.auth().currentUser  == nil){
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "authVC") {
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.present(vc, animated: true, completion: nil)

            }
        }else{
            Utilities.init().toMainVC(vc: self, storyboard: self.storyboard!, identifier: "mainVCNavigation")
        }

    }







}

//extention to AuthViewController class
//extention to  text field
//changes the input in the text fields:
//emails and passwords to restrict num of characters and symbols inputed
extension AuthVC{


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
