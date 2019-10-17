//
//  VerificationController.swift
//  FireWatch
//
//  Created by mac on 10/19/18.
//  Copyright © 2018 Ali Kelkawi. All rights reserved.
//

import UIKit
import KWVerificationCodeView
import FirebaseAuth
import SVProgressHUD

class VerificationController: UIViewController {

    @IBOutlet weak var userVerificationCode: KWVerificationCodeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userVerificationCode.keyboardType = .numberPad
    }
    
    @IBAction func verifyPressed(_ sender: Any) {
        SVProgressHUD.show()
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        print("Verification ID: " + verificationID!)
        
        let verificationCode = userVerificationCode.getVerificationCode()
        print(verificationCode)
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: verificationCode)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if let error = error {
                print(error)
                return
            }
            print("User successfully signed in")
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "logInSegue", sender: self)
            
        }
    }

}
