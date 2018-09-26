
import UIKit
import Firebase

enum ThoughtCategory: String {
  case funny = "funny"
  case serious = "serious"
  case crazy = "crazy"
  case popular = "popular"
}

class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  // Outlets
  @IBOutlet private weak var segmentControl: UISegmentedControl!
  @IBOutlet private weak var tableView: UITableView!
  
  // Variables
  private var thoughts = [Thought]()
  private var thoughtsCollectionRef: CollectionReference!
  private var thoughtsListener: ListenerRegistration!
  private var selectedCategory = ThoughtCategory.funny.rawValue
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 100
    tableView.rowHeight = UITableView.automaticDimension
    
    thoughtsCollectionRef = Firestore.firestore().collection(THOUGHTS_REF)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setListner()
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    thoughtsListener.remove()
  }
  
  func setListner() {
    
    if selectedCategory == ThoughtCategory.popular.rawValue {
      thoughtsListener = thoughtsCollectionRef.order(by: NUM_LIKES, descending: true)
        .addSnapshotListener { (snapshot, error) in
          if let error = error {
            debugPrint("Error fetching docs: \(error)")
          } else {
            self.thoughts = Thought.parseData(snapshot: snapshot)
          }
          self.tableView.reloadData()
      }
      
    } else {
      thoughtsListener = thoughtsCollectionRef.whereField(CATEGORY, isEqualTo: selectedCategory)
        .order(by: TIMESTAMP, descending: true)
        .addSnapshotListener { (snapshot, error) in
          if let error = error {
            debugPrint("Error fetching docs: \(error)")
          } else {
            self.thoughts = Thought.parseData(snapshot: snapshot)
          }
          self.tableView.reloadData()
      }
      
    }
    
  }
  
  @IBAction func onCategoryChanged(_ sender: Any) {
    thoughts.removeAll()
    
    switch segmentControl.selectedSegmentIndex {
    case 0:
      selectedCategory = ThoughtCategory.funny.rawValue
    case 1:
      selectedCategory = ThoughtCategory.serious.rawValue
    case 2:
      selectedCategory = ThoughtCategory.crazy.rawValue
    default:
      selectedCategory = ThoughtCategory.popular.rawValue
    }
    
    thoughtsListener.remove()
    setListner()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return thoughts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "thoughtCell", for: indexPath) as? ThoughtCell {
      cell.configureCell(thought: thoughts[indexPath.row])
      return cell
    } else { return UITableViewCell() }
  }
  
}

