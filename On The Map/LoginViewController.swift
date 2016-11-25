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
        appDelegate = UIApplication.shared.delegate as! AppDelegate                        
        
        configureUI()
        self.hideKeyboardWhenTappedAround()
        
        subscribeToNotification(NSNotification.Name.UIKeyboardWillShow.rawValue, selector: #selector(keyboardWillShow))
        subscribeToNotification(NSNotification.Name.UIKeyboardWillHide.rawValue, selector: #selector(keyboardWillHide))
        subscribeToNotification(NSNotification.Name.UIKeyboardDidShow.rawValue, selector: #selector(keyboardDidShow))
        subscribeToNotification(NSNotification.Name.UIKeyboardDidHide.rawValue, selector: #selector(keyboardDidHide))
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        UITextField.appearance().tintColor = UIColor.lightGray  // change cursor color to make it visible on white background
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        
        
        // ***************  TOGGLE TO TURN IN OR DEVELOP  ********************
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
        let message = "Username and/or Password Empty."
        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        } else {
            setUIEnabled(false)
            udacityLogin()
        }
        // REMOVE or COMMENT OUT
//        setUIEnabled(false)
//        udacityLogin()
        // ************************************************************************
        
        userDidTapView(self)

    }
    
    fileprivate func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "MapsTabBarViewController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: Udacity
    
    fileprivate func udacityLogin() {
        
        // hide keyboard
        self.view.endEditing(true)
        // ***************  TOGGLE TO TURN IN ********************
        let email =  emailTextField.text! as String
        let password = passwordTextField.text! as String
        // *******************************************************
        
        let postJsonBody = NSString(format:
            "{\"udacity\": {\"username\": \"\(email)\", \"password\":\"\(password)\"}}" as NSString)
        
        self.getKeyAndSession(postJsonBody: postJsonBody)

    }

    
    fileprivate func getKeyAndSession(postJsonBody: AnyObject) {
        
        let jsonBody = postJsonBody as! String
        
        let alert = UIAlertController(title: nil, message: "Standby...", preferredStyle: .alert)

        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:10, y:5, width:50, height:50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        UdacityClient.sharedInstance().getKeyAndSession(jsonBody as AnyObject) { (results, error) in
            if error != nil {
                self.dismiss(animated: false, completion: nil) // dismiss activity alert to show error alert

                print(error ?? "Error getting key and sessionID")
                let message = error! as String
                let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                // Sucessfully acquired key and sessionID
                self.getUserData()
                self.completeLogin()
                self.dismiss(animated: false, completion: nil)
            }
        }
        self.setUIEnabled(true)

    }
    
    fileprivate func getUserData() {
        let udacityKey = UdacityClient.sharedInstance().udacityKey
        let requestString = "https://www.udacity.com/api/users/\(udacityKey)"
        UdacityClient.sharedInstance().getUserDataFromUdacity(requestString) { (results, error) in
            if error != nil {
                DispatchQueue.main.async(execute: {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            mapImageView.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            mapImageView.isHidden = false
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    fileprivate func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    fileprivate func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(emailTextField)
        resignIfFirstResponder(passwordTextField)
    }
    
    // Udacity Sign Up Button
    @IBAction func UdacitySignUp(_ sender: UIButton) {
        let udacitySignUpURL = Constants.Udacity.UdacitySignUpURL
        UIApplication.shared.openURL(URL(string: udacitySignUpURL)!)
    }
}

// MARK: - LoginViewController (Configure UI)

extension LoginViewController {
    
    fileprivate func setUIEnabled(_ enabled: Bool) {
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    fileprivate func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        configureTextField(emailTextField)
        configureTextField(passwordTextField)
    }
    
    fileprivate func configureTextField(_ textField: UITextField) {
        let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.white // Constants.UI.OrangeColor //Constants.UI.GreyColor
        textField.backgroundColor?.withAlphaComponent(0.5)
        textField.textColor = Constants.UI.OrangeColor //Constants.UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: Constants.UI.OrangeColor])  // was UIColor.whiteColor()
        textField.tintColor = UIColor.white // Constants.UI.BlueColor
        textField.delegate = self
    }
    
    internal func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if emailTextField.isFirstResponder == true {
            emailTextField.placeholder = ""
        }
        
        if passwordTextField.isFirstResponder == true {
            passwordTextField.placeholder = ""
        }
    }
}

// MARK: - LoginViewController (Notifications)

extension LoginViewController {
    
    fileprivate func subscribeToNotification(_ notification: String, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: notification), object: nil)
    }
    
    fileprivate func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
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
