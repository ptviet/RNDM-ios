
import UIKit
import Firebase

protocol CommentDelegate {
  func optionsTapped(comment: Comment)
}

class CommentCell: UITableViewCell {
  
  // Outlets
  @IBOutlet weak var usernameLbl: UILabel!
  @IBOutlet weak var timestampLbl: UILabel!
  @IBOutlet weak var commentLbl: UILabel!
  @IBOutlet weak var optionsMenu: UIImageView!
  
  // Variables
  private var comment: Comment!
  private var delegate: CommentDelegate?
  
  func configureCell(comment: Comment, delegate: CommentDelegate?) {
    optionsMenu.isHidden = true
    self.comment = comment
    self.delegate = delegate
    
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM, hh:mm"
    let timestamp = formatter.string(from: comment.timestamp)
    
    usernameLbl.text = comment.username
    timestampLbl.text = timestamp
    commentLbl.text = comment.commentTxt
    
    if comment.userId == Auth.auth().currentUser?.uid {
      optionsMenu.isHidden = false
      optionsMenu.isUserInteractionEnabled = true
      let tap = UITapGestureRecognizer(target: self, action: #selector(optionsTapped))
      optionsMenu.addGestureRecognizer(tap)
    }
    
  }
  
  @objc func optionsTapped() {
    delegate?.optionsTapped(comment: comment)
  }
  
}
