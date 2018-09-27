
import UIKit

class CommentCell: UITableViewCell {
  
  // Outlets
  @IBOutlet weak var usernameLbl: UILabel!
  @IBOutlet weak var timestampLbl: UILabel!
  @IBOutlet weak var commentLbl: UILabel!
  
  func configureCell(comment: Comment) {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM, hh:mm"
    let timestamp = formatter.string(from: comment.timestamp)
    
    usernameLbl.text = comment.username
    timestampLbl.text = timestamp
    commentLbl.text = comment.commentTxt
    
  }
  
}
