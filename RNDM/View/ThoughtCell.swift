import UIKit
import Firebase

protocol ThoughtDelegate {
  func optionsTapped(thought: Thought)
}

class ThoughtCell: UITableViewCell {
  
  // Outlets
  @IBOutlet weak var usernameLbl: UILabel!
  @IBOutlet weak var timestampLbl: UILabel!
  @IBOutlet weak var thoughtTxtLbl: UILabel!
  @IBOutlet weak var likesImg: UIImageView!
  @IBOutlet weak var likesNumLbl: UILabel!
  @IBOutlet weak var commentsNumLbl: UILabel!
  @IBOutlet weak var optionsMenu: UIImageView!
  
  // Variables
  private var thought: Thought!
  private var delegate: ThoughtDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
    likesImg.addGestureRecognizer(tap)
    likesImg.isUserInteractionEnabled = true
    
  }
  
  @objc func likeTapped() {
    // Method 1
//    Firestore.firestore().collection(THOUGHTS_REF).document(thought.documentId).setData([NUM_LIKES : thought.numLikes + 1], merge: true)
    
    // Method 2
    Firestore.firestore().document("\(THOUGHTS_REF)/\(thought.documentId!)").updateData([NUM_LIKES : thought.numLikes + 1])
    
  }
  
  func configureCell(thought: Thought, delegate: ThoughtDelegate?) {
    optionsMenu.isHidden = true
    
    self.thought = thought
    self.delegate = delegate
    
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM, hh:mm"
    let timestamp = formatter.string(from: thought.timestamp)
    
    usernameLbl.text = thought.username
    timestampLbl.text = timestamp
    thoughtTxtLbl.text = thought.thoughtTxt
    likesNumLbl.text = "\(thought.numLikes!)"
    commentsNumLbl.text = "\(thought.numComments!)"
    
    if thought.userId == Auth.auth().currentUser?.uid {
      optionsMenu.isHidden = false
      optionsMenu.isUserInteractionEnabled = true
      let tap = UITapGestureRecognizer(target: self, action: #selector(optionsTapped))
      optionsMenu.addGestureRecognizer(tap)
    }
    
  }
  
  @objc func optionsTapped() {
    delegate?.optionsTapped(thought: thought)
  }
  
}
