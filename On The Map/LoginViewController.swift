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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        
        
        // ***************  SWITCH BACK TO TURN IN OR DEVELOP  ********************
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            udacityLogin()
        }
        // REMOVE
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
        // ***************  CHANGE TO TURN IN ********************
        let email =  emailTextField.text! as String
        let password = passwordTextField.text! as String
        // *******************************************************
        
        // let parameters = ["":""]
        let postJsonBody = NSString(format:
            "{\"udacity\": {\"username\": \"\(email)\", \"password\":\"\(password)\"}}" as NSString)
        
        self.getKeyAndSession(postJsonBody: postJsonBody)

    }

    
    fileprivate func getKeyAndSession(postJsonBody: AnyObject) {
        /* 1. Set the parameters */
        /* 2/3. Build the URL, Configure the request */
        let jsonBody = postJsonBody as! String

        
        /* 4. Make the request */
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        // request.httpBody = "{\"udacity\": {\"username\": \"account@domain.com\", \"password\": \"********\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        DispatchQueue.main.async(execute: {

        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            // Check for errors
            func sendError(_ error: String) {
                print(error)
                print("Send error is called")
                self.setUIEnabled(true)

                self.debugTextLabel.text = "Login error\n\(error)"
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let status = (response as? HTTPURLResponse)?.statusCode
                print("The status from get user data is  \(status)")
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            if error != nil {
                self.debugTextLabel.text = "Login error"
            } else {
                do {
                    let range = Range(uncheckedBounds: (5, data.count))
                    let newData = data.subdata(in: range) /* subset response data! */

                    let parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
                    
                    UdacityClient.sharedInstance().udacityKey = ((parsedResult["account"] as! [String : AnyObject])["key"] as! String)
                    UdacityClient.sharedInstance().sessionId = ((parsedResult["session"] as! [String : AnyObject])["id"] as! String)
                    print("Key is \(UdacityClient.sharedInstance().udacityKey) and sessionID is \(UdacityClient.sharedInstance().sessionId)")
                    
                    self.getUserData()
                    self.completeLogin()
                    
                } catch {
                    self.debugTextLabel.text = "Login error"
                }
            }
            
        }
        task.resume()

        }) // return from main thread process

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
