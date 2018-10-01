
import UIKit
import Firebase

class UpdateCommentVC: UIViewController, UITextViewDelegate {
  
  // Outlets
  @IBOutlet weak var commentTxt: UITextView!
  @IBOutlet weak var updateBtn: UIButton!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  
  // Variables
  var commentData: (comment: Comment, thought: Thought)!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateBtn.isEnabled = true
    spinner.isHidden = true
    updateBtn.layer.cornerRadius = 4
    commentTxt.layer.cornerRadius = 4
    
    commentTxt.text = commentData.comment.commentTxt
    commentTxt.textColor = UIColor.lightGray
    commentTxt.delegate = self
    
    let toggleKeyboard = UITapGestureRecognizer(target: self, action: #selector(handleToggleKeyboard))
    toggleKeyboard.cancelsTouchesInView = false
    
    view.addGestureRecognizer(toggleKeyboard)
  }
  
  @objc func handleToggleKeyboard() {
    view.endEditing(true)
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    commentTxt.textColor = UIColor.darkGray
  }
  
  @IBAction func onUpdateBtnPressed(_ sender: Any) {
    guard let comment = commentTxt.text else { return }

    if comment != "" {
      updateBtn.isEnabled = false
      spinner.isHidden = false
      spinner.startAnimating()
      Firestore.firestore().collection(THOUGHTS_REF).document(commentData.thought.documentId).collection(COMMENTS_REF).document(commentData.comment.documentId)
        .updateData([COMMENT_TEXT : comment]) { (error) in
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
