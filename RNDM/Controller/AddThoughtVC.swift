
import UIKit
import Firebase

class AddThoughtVC: UIViewController, UITextViewDelegate {
  
  // Outlets
  @IBOutlet private weak var categorySegment: UISegmentedControl!
  @IBOutlet private weak var thoughtTxtView: UITextView!
  @IBOutlet private weak var postBtn: UIButton!
  @IBOutlet private weak var spinner: UIActivityIndicatorView!
  
  // Variables
  private var selectedCategory: String = ThoughtCategory.funny.rawValue
  
  override func viewDidLoad() {
    super.viewDidLoad()
    spinner.isHidden = true
    
    postBtn.layer.cornerRadius = 4
    thoughtTxtView.layer.cornerRadius = 4
    
    thoughtTxtView.text = "My random thought..."
    thoughtTxtView.textColor = UIColor.lightGray
    thoughtTxtView.delegate = self
    
    let toggleKeyboard = UITapGestureRecognizer(target: self, action: #selector(handleToggleKeyboard))
    toggleKeyboard.cancelsTouchesInView = false
    
    view.addGestureRecognizer(toggleKeyboard)
    
  }
  
  @objc func handleToggleKeyboard() {
    view.endEditing(true)
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if thoughtTxtView.text == "My random thought..." {
      thoughtTxtView.text = ""
    }
    thoughtTxtView.textColor = UIColor.darkGray
  }
  
  @IBAction func onCategoryChanged(_ sender: Any) {
    switch categorySegment.selectedSegmentIndex {
    case 0:
      selectedCategory = ThoughtCategory.funny.rawValue
    case 1:
      selectedCategory = ThoughtCategory.serious.rawValue
    case 2:
      selectedCategory = ThoughtCategory.crazy.rawValue
    default:
      selectedCategory = ThoughtCategory.funny.rawValue
    }
  }
  
  @IBAction func onPostBtnPressed(_ sender: Any) {
    guard let thought = thoughtTxtView.text else { return }
    
    if thought != "" {
      guard let username = Auth.auth().currentUser?.displayName else { return }
      spinner.isHidden = false
      spinner.startAnimating()
      
      Firestore.firestore().collection(THOUGHTS_REF).addDocument(data: [CATEGORY : selectedCategory,
                                                                      NUM_COMMENTS: 0,
                                                                      NUM_LIKES: 0,
                                                                      THOUGHT_TEXT: thought,
                                                                      TIMESTAMP: FieldValue.serverTimestamp(),
                                                                      USERNAME: username])
      { (error) in
        if let error = error {
          debugPrint("Error adding document: \(error)")
        } else {
          self.spinner.isHidden = true
          self.spinner.stopAnimating()
          self.navigationController?.popViewController(animated: true)
        }
      }
      
    }
  }
  
}
