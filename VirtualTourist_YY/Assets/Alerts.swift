//
//  Alerts.swift
//  VirtualTourist_YY
//
//  Created by MacAir11 on 2019/12/21.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

extension UIViewController{
    func showAlert(title:String,message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            // do nothing
        }
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
