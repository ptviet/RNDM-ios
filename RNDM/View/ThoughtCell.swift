import UIKit
import Firebase

class ThoughtCell: UITableViewCell {
  
  // Outlets
  @IBOutlet weak var usernameLbl: UILabel!
  @IBOutlet weak var timestampLbl: UILabel!
  @IBOutlet weak var thoughtTxtLbl: UILabel!
  @IBOutlet weak var likesImg: UIImageView!
  @IBOutlet weak var LikesNumLbl: UILabel!
  
  // Variables
  private var thought: Thought!
  
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
  
  func configureCell(thought: Thought) {
    self.thought = thought
    
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM, hh:mm"
    let timestamp = formatter.string(from: thought.timestamp)
    
    usernameLbl.text = thought.username
    timestampLbl.text = timestamp
    thoughtTxtLbl.text = thought.thoughtTxt
    LikesNumLbl.text = "\(thought.numLikes!)"
  }
  
}
