
import UIKit
import Firebase

class RegisterVC: UIViewController {
  
  // Outlets
  @IBOutlet weak var emailTxt: UITextField!
  @IBOutlet weak var passwordTxt: UITextField!
  @IBOutlet weak var usernameTxt: UITextField!
  @IBOutlet weak var registerBtn: UIButton!
  @IBOutlet weak var cancelBtn: UIButton!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  
  // Variables
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.spinner.isHidden = true
    
    registerBtn.layer.cornerRadius = 10
    cancelBtn.layer.cornerRadius = 10
    
    let toggleKeyboard = UITapGestureRecognizer(target: self, action: #selector(handleToggleKeyboard))
    toggleKeyboard.cancelsTouchesInView = false
    
    view.addGestureRecognizer(toggleKeyboard)
    
  }
  
  @objc func handleToggleKeyboard() {
    view.endEditing(true)
  }
  
  @IBAction func onRegisterBtnPressed(_ sender: Any) {
    guard let email = emailTxt.text,
      let password = passwordTxt.text,
      let username = usernameTxt.text else { return }
    
    if email != "" && password != "" && username != "" {
      spinner.isHidden = false
      spinner.startAnimating()
      
      Auth.auth().createUser(withEmail: emailTxt.text!, password: passwordTxt.text!) { (user, error) in
        if let error = error {
          debugPrint("Error registering user: \(error)")
        } else {
          let changeRequest = user?.user.createProfileChangeRequest()
          changeRequest?.displayName = username
          changeRequest?.commitChanges(completion: { (error) in
            if let error = error {
              debugPrint(error.localizedDescription)
            }
          })
          
          guard let userId = user?.user.uid else { return }
          Firestore.firestore().collection(USERS_REF).document(userId).setData(
            [
              USERNAME: username,
              DATE_CREATED: FieldValue.serverTimestamp()
            ], completion: { (error) in
              if let error = error {
                debugPrint(error.localizedDescription)
              } else {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.dismiss(animated: true, completion: nil)
              }
          })
          
        }
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
      }
      
    }
    
  }
  
  @IBAction func onCancelBtnPressed(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
}
