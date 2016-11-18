//
//  LoginViewController.swift
//  On The Map
//
//  Created by Paul ReFalo on 10/19/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var debugTextLabel: UILabel!        
    @IBOutlet weak var mapImageView: UIImageView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate                        
        
        configureUI()
        self.hideKeyboardWhenTappedAround()
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(keyboardWillHide))
        subscribeToNotification(UIKeyboardDidShowNotification, selector: #selector(keyboardDidShow))
        subscribeToNotification(UIKeyboardDidHideNotification, selector: #selector(keyboardDidHide))
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        
        // ***************  SWITCH BACK TO TURN IN OR DEVELOP  ********************
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            udacityLogin()
        }
        // ************************************************************************
        
        userDidTapView(self)

    }
    

    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapsTabBarViewController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: Udacity
    
    private func udacityLogin() {
        
        // hide keyboard
        self.view.endEditing(true)
        // ***************  CHANGE TO TURN IN ********************
        let email =  emailTextField.text! as String
        let password =  passwordTextField.text! as String
        // *******************************************************
        
        let parameters = ["":""]
        let postJsonBody = NSString(format:
            "{\"udacity\": {\"username\": \"\(email)\", \"password\":\"\(password)\"}}")
        
        // Udacity user login
        UdacityClient.sharedInstance().taskForPOSTMethod(Constants.Udacity.UdacityPostApiSession, parameters: parameters, jsonBody: postJsonBody as String) { (results, error) in


            if error != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.debugTextLabel.text = "Login failed"
                })
            } else {
                // Go to complete login and then onto map tab view
                print("Udacity login successful!!!!!!")
                dispatch_async(dispatch_get_main_queue(), {

                    let x = UdacityClient.sharedInstance().udacityKey
                    print("The key is \(x)")
                    self.completeLogin()
                })
                
                // Now get and store User Data from Udacity
                self.getUserData()
            }
        }
        self.setUIEnabled(true)
    }
    
    private func getUserData() {
        let udacityKey = UdacityClient.sharedInstance().udacityKey
        let requestString = "https://www.udacity.com/api/users/\(udacityKey)"
        UdacityClient.sharedInstance().getUserDataFromUdacity(requestString) { (results, error) in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.debugTextLabel.text = "Could Not Your Data"

                })
            }
            // Success getting user data
        }
        self.setUIEnabled(true)
    }
    
    
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            mapImageView.hidden = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            mapImageView.hidden = false
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(emailTextField)
        resignIfFirstResponder(passwordTextField)
    }
    
    // Udacity Sign Up Button
    @IBAction func UdacitySignUp(sender: UIButton) {
        let udacitySignUpURL = Constants.Udacity.UdacitySignUpURL
        UIApplication.sharedApplication().openURL(NSURL(string: udacitySignUpURL)!)
    }
}

// MARK: - LoginViewController (Configure UI)

extension LoginViewController {
    
    private func setUIEnabled(enabled: Bool) {
        emailTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    private func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        configureTextField(emailTextField)
        configureTextField(passwordTextField)
    }
    
    private func configureTextField(textField: UITextField) {
        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .Always
        textField.backgroundColor = UIColor.whiteColor() // Constants.UI.OrangeColor //Constants.UI.GreyColor
        textField.backgroundColor?.colorWithAlphaComponent(0.5)
        textField.textColor = Constants.UI.OrangeColor //Constants.UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: Constants.UI.OrangeColor])  // was UIColor.whiteColor()
        textField.tintColor = UIColor.whiteColor() // Constants.UI.BlueColor
        textField.delegate = self
    }
    
    private func textFieldDidBeginEditing(textField: UITextField) {
        
        if emailTextField.isFirstResponder() == true {
            emailTextField.placeholder = ""
        }
        
        if passwordTextField.isFirstResponder() == true {
            passwordTextField.placeholder = ""
        }
    }
}

// MARK: - LoginViewController (Notifications)

extension LoginViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}