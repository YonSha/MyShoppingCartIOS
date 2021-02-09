//
//  Utilities.swift
//  MyShoppingCart
//
//  Created by pc on 19/11/2019.
//  Copyright © 2019 yonsProject. All rights reserved.
//

import Foundation
import UIKit


class Utilities{
    
 
    
    
    ///simple alert helper func:
    func showAlert(title: String, message: String, vc: UIViewController){
        
        
        let newAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        newAlert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        
        vc.present(newAlert, animated: true, completion: nil)
    }
    
    //get current date helper func:
    func getDate () -> String {
        
        let date: Date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        
        return dateFormatter.string(from: date)
    }
    
    
    //send to another vc helper func:
    func toMainVC(vc:UIViewController, storyboard:UIStoryboard, identifier:String) {
        
    let toMainVC = vc.storyboard?.instantiateViewController(withIdentifier:identifier )
        
        vc.present(toMainVC!, animated: true, completion: nil)
    }
    
    
    
    //send to another vc helper func:
    func sendToAnotherVC(vc:UIViewController, storyboard:UIStoryboard, identifier:String) {
        
        let anotherVC = vc.storyboard?.instantiateViewController(withIdentifier:identifier )
        
        vc.present(anotherVC!, animated: true, completion: nil)
    }
    
    
    
    
    
    
}
