
import UIKit
import Firebase

class AddCommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  // Outlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var commentTxtField: UITextField!
  @IBOutlet weak var keyboardView: UIView!
  
  // Variables
  var comments = [Comment]()
  var thought: Thought!
  var thoughtRef: DocumentReference!
  let firestore = Firestore.firestore()
  var username: String!
  var commentListener: ListenerRegistration!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    thoughtRef = firestore.collection(THOUGHTS_REF).document(thought.documentId)
    if let displayName = Auth.auth().currentUser?.displayName {
      username = displayName
    }
    
    view.bindToKeyboard()
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 100
    tableView.rowHeight = UITableView.automaticDimension
    
    let toggleKeyboard = UITapGestureRecognizer(target: self, action: #selector(handleToggleKeyboard))
//    toggleKeyboard.cancelsTouchesInView = false
    view.addGestureRecognizer(toggleKeyboard)
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    commentListener = thoughtRef.collection(COMMENTS_REF)
      .order(by: TIMESTAMP, descending: false)
      .addSnapshotListener({ (snapshot, error) in
      if let error = error {
        debugPrint(error.localizedDescription)
      } else {
        self.comments.removeAll()
        guard let snapshot = snapshot else { return }
        self.comments = Comment.parseData(snapshot: snapshot)
      }
      self.tableView.reloadData()
    })
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    if commentListener != nil {
      commentListener.remove()
    }
  }
  
  @objc func handleToggleKeyboard() {
    view.endEditing(true)
  }
  
  @IBAction func onSendCommentPressed(_ sender: Any) {
    guard let comment = commentTxtField.text else { return }
    if comment != "" {
      firestore.runTransaction({ (transaction, errorPointer) -> Any? in
        var thoughtDoc: DocumentSnapshot
        
        do {
          try thoughtDoc = transaction.getDocument(self.thoughtRef)

        } catch let error as NSError {
          debugPrint(error.localizedDescription)
          return nil
        }
        
        guard let prevCommentsNum = thoughtDoc.data()?[NUM_COMMENTS] as? Int else { return nil }
        transaction.updateData([NUM_COMMENTS : prevCommentsNum + 1], forDocument: self.thoughtRef)
        let newCommentRef = self.thoughtRef.collection(COMMENTS_REF).document()
        transaction.setData([COMMENT_TEXT : comment,
                             TIMESTAMP: FieldValue.serverTimestamp(),
                             USERNAME: self.username], forDocument: newCommentRef)
        
        return nil
      }) { (object, error) in
        if let error = error {
          debugPrint(error.localizedDescription)
        } else {
          self.commentTxtField.text = ""
          self.commentTxtField.resignFirstResponder()
        }
      }
    }
    
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentCell else { return UITableViewCell()}
    
    cell.configureCell(comment: comments[indexPath.row])
    
    return cell
  }
  
}
