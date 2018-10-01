
import UIKit
import Firebase

class AddCommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentDelegate {

  // Outlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var commentTxtField: UITextField!
  @IBOutlet weak var keyboardView: UIView!
  @IBOutlet weak var sendBtn: UIButton!
  
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
    
//    let toggleKeyboard = UITapGestureRecognizer(target: self, action: #selector(handleToggleKeyboard))
//    toggleKeyboard.cancelsTouchesInView = false
//    view.addGestureRecognizer(toggleKeyboard)
    
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
      sendBtn.isEnabled = false
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
                             USERNAME: self.username,
                             USER_ID: Auth.auth().currentUser?.uid ?? ""], forDocument: newCommentRef)
        
        return nil
      }) { (object, error) in
        if let error = error {
          debugPrint(error.localizedDescription)
        } else {
          self.sendBtn.isEnabled = true
          self.commentTxtField.text = ""
          self.commentTxtField.resignFirstResponder()
        }
      }
    }
    
  }
  
  func optionsTapped(comment: Comment) {
    let alert = UIAlertController(title: "Actions", message: "Edit or Delete", preferredStyle: .actionSheet)
    
    let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
      self.firestore.runTransaction({ (transaction, errorPointer) -> Any? in
        var thoughtDoc: DocumentSnapshot
        
        do {
          try thoughtDoc = transaction.getDocument(self.thoughtRef)
          
        } catch let error as NSError {
          debugPrint(error.localizedDescription)
          return nil
        }
        
        guard let prevCommentsNum = thoughtDoc.data()?[NUM_COMMENTS] as? Int else { return nil }
        transaction.updateData([NUM_COMMENTS : prevCommentsNum - 1], forDocument: self.thoughtRef)

        let commentRef = self.firestore.collection(THOUGHTS_REF).document(self.thought.documentId).collection(COMMENTS_REF).document(comment.documentId)
        
        transaction.deleteDocument(commentRef)
        
        return nil
      }) { (object, error) in
        if let error = error {
          debugPrint(error.localizedDescription)
        } else {
          alert.dismiss(animated: true, completion: nil)
        }
      }
      
    }
    
    let editAction = UIAlertAction(title: "Edit", style: .default) { (action) in
      self.performSegue(withIdentifier: "toUpdateCommentVC", sender: (comment, self.thought))
      alert.dismiss(animated: true, completion: nil)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alert.addAction(deleteAction)
    alert.addAction(editAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? UpdateCommentVC {
      if let commentData = sender as? (comment: Comment, thought: Thought) {
        destination.commentData = commentData
      }
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentCell else { return UITableViewCell()}
    
    cell.configureCell(comment: comments[indexPath.row], delegate: self)
    
    return cell
  }
  
}
