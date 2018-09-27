
import UIKit
import Firebase

class LoginVC: UIViewController {
  
  // Outlets
  @IBOutlet weak var emailTxt: UITextField!
  @IBOutlet weak var passwordTxt: UITextField!
  @IBOutlet weak var loginBtn: UIButton!
  @IBOutlet weak var registerBtn: UIButton!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    spinner.isHidden = true
    
    loginBtn.layer.cornerRadius = 10
    registerBtn.layer.cornerRadius = 10
    
    let toggleKeyboard = UITapGestureRecognizer(target: self, action: #selector(handleToggleKeyboard))
    toggleKeyboard.cancelsTouchesInView = false
    
    view.addGestureRecognizer(toggleKeyboard)
    
  }
  
  @objc func handleToggleKeyboard() {
    view.endEditing(true)
  }
  
  @IBAction func onLoginBtnPressed(_ sender: Any) {
    guard let email = emailTxt.text,
          let password = passwordTxt.text else { return }
    
    if email != "" && password != "" {
      spinner.isHidden = false
      spinner.startAnimating()
      
      Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
        if let error = error {
          debugPrint("Error signing in: \(error)")
        } else {
          self.spinner.isHidden = true
          self.spinner.stopAnimating()
          self.dismiss(animated: true, completion: nil)
        }
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
      }
    }
    
  }  
  
}
