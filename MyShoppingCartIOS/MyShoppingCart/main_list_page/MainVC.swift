//
//  MainVC.swift
//  MyShoppingCart
//
//  Created by pc on 17/11/2019.
//  Copyright © 2019 yonsProject. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase


class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate{
   
    @IBOutlet weak var numberOfProductsLabel: UILabel!
    
    @IBOutlet weak var addAlertBox: UIView!
    
    
    @IBOutlet weak var addItemBtn: UIButton!
    
   
    @IBOutlet weak var tableView: UITableView!
    
    //vars:
    var items: [DataSnapshot] = [DataSnapshot] ()
    var itemIDS: [String] = [String]()
    var listID:String = "none"
    
    
    //firebase init:
    var ref:DatabaseReference!
    var refHandler:DatabaseHandle!
  
    var productsMsg:String = String()
    var products:Int = Int()
    
    
    @IBOutlet weak var quantityDialog: UITextField!
    
    @IBOutlet weak var descDialog: UITextField!
    
    @IBOutlet weak var titleDialog: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        checkCurrentUser()
        
        //database reference:
                  ref = Database.database().reference()
        
  //load data from firebase
        getListID()
        
        productsMsg = numberOfProductsLabel.text!
        
    
     
        updateNumberOfProductsFromDatabase()
        
        
        self.addAlertBox.layer.borderWidth = 1
        self.addAlertBox.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        //locate the dialog above the main view:
        self.addAlertBox.center = CGPoint(x: self.view.frame.midX, y: -self.view.frame.height / 2)
        
      
      //cell seperator line from edge to edge
        //more in cell func
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
   
        
        
        
        //delegates:
        tableView.delegate = self
        tableView.dataSource = self
        
        self.quantityDialog.delegate = self
        self.descDialog.delegate = self
        self.titleDialog.delegate = self
        
        
    
        
        
    }
    
    
    
    func getListID(){
        
        if(Auth.auth().currentUser != nil){ self.ref.child("Users").child(Auth.auth().currentUser!.uid).child("userDetails").child("listID").observeSingleEvent(of: .value, with: { (snapshot) in
                  // Get user value
                  let value = snapshot.value as? NSDictionary
                    
        let id = value?["listID"] as? String
                self.listID =  id ?? "none"
            self.setupFireBase();
        
            self.tableView.reloadData()
                  // ...
                  }) { (error) in
                    print(error.localizedDescription)
                }
                
        }
    }
    
    
    
    func updateNumberOfProductsFromDatabase(){
 
         self.ref.child("carts").child(listID).child("myItems").observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
     
            self.products = snapshot.accessibilityElementCount()
     

          // ...
          }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
        
        self.ref.child("carts").child(listID).observe(DataEventType.childAdded, with:  { (dataSnapshot) in
          
            
            
            _ = self.ref.child("myCart").observe(DataEventType.value, with: { (snapshot) in
             let postDict = snapshot.value as? [String : AnyObject] ?? [:]
           
               // self.products = postDict["products"] as! Int
               
          //      self.numberOfProductsLabel.text? = self.productsMsg + String(describing: self.products)
                
                
           })
       
       
               
               
           })
}
    
    //remove all items from the database/tableview
    @IBAction func removeAllBtn(_ sender: UIButton) {
        
        self.ref.child("carts").child(listID).child("myItems").removeValue()

     clearReloadData()
    }
    
    
    @IBAction func addItemBtn(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.5) { [weak self] in
                   self?.addAlertBox.center =  self?.view.center ?? CGPoint(x: 0, y: 0)
               }
        
        //addAlertBox.center = self.view.center
        self.view.addSubview(addAlertBox)
        
        
    }
    
    
    
    @IBAction func cancelDialog(_ sender: UIButton) {
        
   
    dismissDialog()
        
        
    }
    
    @IBAction func additemDialog(_ sender: UIButton) {
        
        if titleDialog.text!.isEmpty {
                 
        }else{
            saveDataToDatabase()
        }
        
        
        dismissDialog()
    }
    
    
    func saveDataToDatabase(){
        
        var data = [String:String]()
        
        data["date"] = Utilities.init().getDate()
        data["description"] = self.descDialog.text
        data["name"] = self.titleDialog.text
        data["quantity"] = self.quantityDialog.text
        
        self.ref.child("carts").child(listID).child("myItems").childByAutoId().setValue(data)
        
        
    
        
         
        
    }
    
    
    func dismissDialog(){
        
        UIView.animate(withDuration: 0.4, animations: {
            
              self.addAlertBox.center = CGPoint(x: self.view.frame.midX, y: -self.view.frame.height / 2)
        }){ (isCompleted) in
          
            self.addAlertBox.removeFromSuperview()
            
        }
        self.descDialog.text = ""
        self.titleDialog.text = ""
        self.quantityDialog.text = "1"
        
        
    }
    
    
    @IBAction func plusBtnDialog(_ sender: UIButton) {
        
        var quantity = Int(quantityDialog.text ?? "1")!
        
            if(quantity>=1&&quantity<9){
                
                quantity += 1
                   quantityDialog.text = String(quantity)
            }
        
    }
    
    @IBAction func minusBtnDialog(_ sender: UIButton) {
        
        
        var quantity = Int(quantityDialog.text ?? "1")!
        if(quantity>1&&quantity<=9){
            
             quantity -= 1
               quantityDialog.text = String(quantity)
        }
    }
    
    
    //clears and reload the fb data to the table view
    func clearReloadData(){
        
        self.itemIDS.removeAll()
        self.items.removeAll()
        self.tableView.reloadData()
        
    }
    
    
    //event listner to the firebase - > if there is a new entry -> add all the entrys into the dictionary -> 'messages'
    // aterwards insert the values into the tableView:
    func setupFireBase() {
        

    
        //added message listner - > if added to FB will be added to the tableView
        _ =  self.ref.child("carts").child(listID).child("myItems").observe(DataEventType.childAdded, with:  { (dataSnapshot) in
            self.items.append(dataSnapshot)
            self.itemIDS.append(dataSnapshot.key)
            
     self.tableView.insertRows(at: [IndexPath(row: self.items.count - 1 , section: 0)], with: .automatic)
            
            
         //   reload the tableView to the last row:
     self.refreshToLastCell()
            
            
        })
        

        
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    
    
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell")! as! ListCell
        
        
          //cell seperator line from edge to edge
        cell.layoutMargins = UIEdgeInsets.zero
        
        let item = items[indexPath.row]

        let itemContent = item.value as! Dictionary<String,NSObject>

        let desc = itemContent["description"]
        let date = itemContent["date"]
        let title = itemContent["name"]
        let quantity = itemContent["quantity"]


        cell.itemDateLabel.text = String(date! as! Substring) 
        cell.itemDescLabel.text = desc  as! String
        cell.itemTitleLabel.text = title  as! String
        cell.itemQuantityLabel.text = String(quantity! as! Substring)
        
        
        
//        if indexPath.row % 2 == 0 {
//            print(indexPath.row)
//            cell.contentView.backgroundColor = UIColor.lightGray
//            
//        }else{
//            
//            cell.contentView.backgroundColor = UIColor.white
//        }
//        
        
        //adds functionality to the cell button:
               cell.removeItemBtn.tag = indexPath.row
               cell.removeItemBtn.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
        
        
  
        return cell
    }
    

    
    //cell button functionality:
    //sender.tag.self -> button index:
    //extract the right index from the IDS array
    //write the requested entries to the database
    //write to the sending user and accepting user logs of the request:
    @objc func buttonSelected(sender: UIButton, path:Int){
        
        let index:Int = sender.tag.self
        
 
        self.ref.child("carts").child(listID).child("myItems").child(itemIDS[index]).removeValue()

      self.itemIDS.remove(at: index)
            self.items.remove(at: index)
            self.tableView.reloadData()
    }
    
    
    
    
    
    
 
    //reload the tableView to the last row:
    func refreshToLastCell() {
        
        //reload the tableView to the last row:
        tableView.reloadData()
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.items.count - 1 , section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
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
           }
           
       }

    
    

    @IBAction func menuBarBtn(_ sender: UIBarButtonItem) {
        
        //alert text attributes:
              let messageFont = [kCTFontAttributeName: UIFont(name: "Avenir-Roman", size: 25.0)!]
              let messageAttrString = NSMutableAttributedString(string: "User Menu", attributes: messageFont as [NSAttributedString.Key : Any])
        
        
        //alert init:
              let topMenuAlert = UIAlertController(title: nil , message: nil, preferredStyle: .actionSheet)
              
              //appliment attribute:
              topMenuAlert.setValue(messageAttrString, forKey: "attributedMessage")
        
        
        //setting btn:
               topMenuAlert.addAction(UIAlertAction(title: "הגדרות", style: .default, handler: { (settingAction) in
                   
                   
                let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "settingsVC")
            
                self.present(settingsVC!, animated: true, completion: nil)
                
                   
               }))
               // about btn:
               topMenuAlert.addAction(UIAlertAction(title: "עלינו", style: .default, handler: { (aboutAction) in
                   
               }))
               //logout btn
               topMenuAlert.addAction(UIAlertAction(title: "התנתק", style: .default, handler: { (logoutAction) in
                   
                   self.logout()
                   self.checkCurrentUser()
                   
               }))
               
               
               topMenuAlert.addAction(UIAlertAction(title: "בטל", style: .destructive, handler: { (logoutAction) in
                   
                   
               }))
               
               self.present(topMenuAlert, animated: true) {
                   
               }
        
    }
    
    
    
    //log out the user of the app
    //if it trows an error the catch phrase will 'catch' that error
    func logout() {
        
        let fAuth =  Auth.auth()
        
        do{
            try fAuth.signOut()
        }catch let signOutError as NSError{
            
            print("error siging out " + signOutError.localizedDescription)
        }
        
        
    }
    

}




extension MainVC{

    
      override  func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        //saves the date and msg to the database via dictionary:
       saveDataToDatabase()
        //clears the chatbox textfield:
        dismissDialog()
        //reload the tableView to the last row:
        refreshToLastCell()
        textField.endEditing(true)
        return true


    }
    
    
    
     public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         
         //max chars allowed ->
         //disable bug that the user cant delete a chars after hiting max chars
        let text = textField.text ?? ""
         let swiftRange = Range(range, in: text)!
         let newString = text.replacingCharacters(in: swiftRange, with: string)
         
         
         if(textField.accessibilityIdentifier == "desc"){
             
             //allowed characters:
             let allowedCharsOne = "abcdefghijklmnopqrstuvwxyz"
             let allowedNumbers = "1234567890"
        
             
             //array of each letter in each allowed propertie:
             let allowedCharsArr = CharacterSet(charactersIn: allowedCharsOne.uppercased() + allowedCharsOne + allowedNumbers)
             
             //the entered text from the user:
             let enteredCharsByUser = CharacterSet(charactersIn: string)
             
             
             
             
             return allowedCharsArr.isSuperset(of: enteredCharsByUser) && newString.count <= 20
         }
         
         
         
         
         return newString.count <= 13
     }
}




