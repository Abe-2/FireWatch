//
//  LoginController.swift
//  FireWatch
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 Ali Kelkawi. All rights reserved.
//

import UIKit
import CountryPicker
import Firebase
import FirebaseAuth
import OnboardKit
import UserNotifications
import CoreLocation

class LoginController: UIViewController, CountryPickerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var flag: UIImageView!
    
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var picker: CountryPicker!
    
    @IBOutlet weak var countryCodeText: UITextField!
    
    //onboarding
//    lazy var onboardingPages: [OnboardPage] = generateOnboardingPages()
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //first time onboarding screen
//        if UserDefaults.standard.value(forKey: "firstIn") == nil {
            showOnboardingTapped()
//        }
        
        
        self.hideKeyboardWhenTappedAround()
        var myColor : UIColor = UIColor( red: 1, green: 0.64, blue:0, alpha: 1.0 )
        phoneNumber.keyboardType = .numberPad
        
        countryCodeText.layer.borderWidth = 2.0
        countryCodeText.layer.cornerRadius = 5.0
        
        myColor = UIColor( red: 1, green: 0, blue:0, alpha: 1.0 )
        
        countryCodeText.delegate = self
        phoneNumber.delegate = self
        
        
        picker.exeptCountriesWithCodes = ["IL"] //except country
        let theme = CountryViewTheme(countryCodeTextColor: .black, countryNameTextColor: .black, rowBackgroundColor: .white, showFlagsBorder: false)        //optional for UIPickerView theme changes
        picker.theme = theme //optional for UIPickerView theme changes
        picker.countryPickerDelegate = self
        picker.showPhoneNumbers = true
        picker.setCountry("KW")
        picker.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == countryCodeText {
            picker.isHidden = false
            countryCodeText.resignFirstResponder()
        } else {
            picker.isHidden = true
        }
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        let countryCode = countryCodeText.text
        let phoneNum = phoneNumber.text
        
        let num = countryCode! + phoneNum!
        
        print(num)
        
        PhoneAuthProvider.provider().verifyPhoneNumber(num, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            self.performSegue(withIdentifier: "verificationSegue", sender: self)
        }
    }
    
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        countryCodeText.text = phoneCode
        self.flag.image = flag
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//onboard functions
extension LoginController {
    func showOnboardingTapped() {
        //save first time use log
        UserDefaults.standard.set(true, forKey: "firstIn")

        let onboard = onBoardVC()
        present(onboard, animated: true, completion: nil)
        
//        let onboardingVC = OnboardViewController(pageItems: onboardingPages)
//        onboardingVC.presentFrom(self, animated: false)
    }
    
//    func generateOnboardingPages() -> [OnboardPage] {
//        let pageOne = OnboardPage(title: "Welcome to FireWatch",
//                                  imageName: "Intro 1",
//                                  description: "A useful tool that allows users to report wildfires quickly and efficiently.")
//        
//        let pageTwo = OnboardPage(title: "Report Easily",
//                                  imageName: "Intro 2",
//                                  description: "Simply login, pin fire location on the map, take a picture and submit.")
//        
//        let pageThree = OnboardPage(title: "Permissions",
//                                    imageName: "Intro 3",
//                                    description: "Turn on your location and allow notification. FireWatch will handle the rest!",
//                                    advanceButtonTitle: "Done",
//                                    actionButtonTitle: "Enable Both",
//                                    action: { [weak self] completion in
//                                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(accepted, error) in
//                                            if !accepted {
//                                                print("Notification access denied.")
//                                            }
//                                        }
//                                        self?.locationManager.requestAlwaysAuthorization()
//        })
//        
//        return [pageOne, pageTwo, pageThree]
//    }
}

func showAlert(title: String?, message: String, parent: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
    alert.addAction(cancelAction)
    parent.present(alert, animated: true, completion: nil)
}
