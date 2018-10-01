
import Foundation
import Firebase

class Comment {
  
  private(set) var documentId: String!
  private(set) var username: String!
  private(set) var timestamp: Date!
  private(set) var commentTxt: String!
  private(set) var userId: String!
  
  init(documentId: String, username: String, timestamp: Date, commentTxt: String, userId: String) {
    self.documentId = documentId
    self.username = username
    self.timestamp = timestamp
    self.commentTxt = commentTxt
    self.userId = userId
    
  }
  
  class func parseData(snapshot: QuerySnapshot?) -> [Comment] {
    var comments = [Comment]()
    guard let snapshot = snapshot else { return comments }
    
    for document in snapshot.documents {
      let data = document.data()
      let documentId = document.documentID
      let username = data[USERNAME] as? String ?? "Anonymous"
      let timestamp = data[TIMESTAMP] as? Date ?? Date()
      let commentTxt = data[COMMENT_TEXT] as? String ?? ""
      let userId = data[USER_ID] as? String ?? ""
      
      let comment = Comment(documentId: documentId, username: username, timestamp: timestamp, commentTxt: commentTxt, userId: userId)
      
      comments.append(comment)
    }
    
    return comments
  }
  
}
