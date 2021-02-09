//
//  AddListVC.swift
//  MyShoppingCart
//
//  Created by pc on 24/12/2019.
//  Copyright © 2019 yonsProject. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase


class AddListVC: UIViewController {
    
    //firebase init:
    var ref:DatabaseReference!
    var refHandler:DatabaseHandle!

    @IBOutlet weak var generateNewListOL: UIButton!
    @IBOutlet weak var insertedListConditionOL: UIButton!
    @IBOutlet weak var currentListOL: UILabel!
    
    @IBOutlet weak var listStartOL: UITextField!
    
    @IBOutlet weak var autoGeneratedListIDOL: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        
        
      
        ref.child("Users").child(Auth.auth().currentUser!.uid).child("userDetails").child("listID").observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
          let value = snapshot.value as? NSDictionary
            
let id = value?["listID"] as? String ?? ""
        self.currentListOL.text  =  id
         

          // ...
          }) { (error) in
            print(error.localizedDescription)
        }
        
      
        
        
        
      
    }
    //  self.ref.child("myCart").child("myItems").childByAutoId().setValue(data)
    @IBAction func generateNewListBtn(_ sender: Any) {
        
        let tempKey = self.ref.childByAutoId().key
        let key = tempKey![3..<11].lowercased()
        
        self.autoGeneratedListIDOL.text =  key.lowercased();

        
        
     }
     
    @IBAction func toUserListBtn(_ sender: UIButton) {
        
        let startListPart = self.listStartOL.text!
        let endListPart = self.autoGeneratedListIDOL.text!
        
              var userDetails = [String:Any]()
        
        userDetails["listID"] = startListPart + endListPart.lowercased()
        
      
        
        
        if endListPart.count < 8 {
            
            
            var alert = UIAlertController(title: "Incorrect List ID", message: "You have entered an invalid list id. please enter a new list ID before advancing further. a list ID should have atleast 8 letters behond the starting three.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        }else{
            
              self.ref.child("Users").child(Auth.auth().currentUser?.uid ?? "").child("userDetails").child("listID").setValue(userDetails)
            
            var data = [String:String]()
             data["products"] = "0"
         
             
            self.ref.child("carts").child(startListPart + endListPart.lowercased()).setValue(data)
             
            
            let toMainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainVCNavigation")
            toMainVC?.modalPresentationStyle = .fullScreen
            self.present(toMainVC!, animated: true, completion: nil)
            
        }
        

        
    }
    
    
    
   
    
}


extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}
