
import Foundation
import Firebase

class Thought {

  private(set) var documentId: String!
  private(set) var username: String!
  private(set) var timestamp: Date!
  private(set) var thoughtTxt: String!
  private(set) var numLikes: Int!
  private(set) var numComments: Int!
  private(set) var userId: String!
  
  init(documentId: String, username: String, timestamp: Date, thoughtTxt: String, numLikes: Int, numComments: Int, userId: String) {
    self.documentId = documentId
    self.username = username
    self.timestamp = timestamp
    self.thoughtTxt = thoughtTxt
    self.numLikes = numLikes
    self.numComments = numComments
    self.userId = userId
  }
  
  class func parseData(snapshot: QuerySnapshot?) -> [Thought] {
    var thoughts = [Thought]()
    guard let snapshot = snapshot else { return thoughts }
    
    for document in snapshot.documents {
      let data = document.data()
      let documentId = document.documentID
      let username = data[USERNAME] as? String ?? "Anonymous"
      let timestamp = data[TIMESTAMP] as? Date ?? Date()
      let thoughtTxt = data[THOUGHT_TEXT] as? String ?? ""
      let numLikes = data[NUM_LIKES] as? Int ?? 0
      let numComments = data[NUM_COMMENTS] as? Int ?? 0
      let userId = data[USER_ID] as? String ?? ""
      
      let thought = Thought(documentId: documentId, username: username, timestamp: timestamp, thoughtTxt: thoughtTxt, numLikes: numLikes, numComments: numComments, userId: userId)
      
      thoughts.append(thought)
    }
    
    return thoughts
  }
  
}
