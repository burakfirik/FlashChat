
import UIKit
import Firebase
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
  
  // Declare instance variables here
  var messageArray: [Message] = [Message]()
  
  // We've pre-linked the IBOutlets
  @IBOutlet var heightConstraint: NSLayoutConstraint!
  @IBOutlet var sendButton: UIButton!
  @IBOutlet var messageTextfield: UITextField!
  @IBOutlet var messageTableView: UITableView!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //TODO: Set yourself as the delegate and datasource here:
    messageTableView.delegate = self
    messageTableView.dataSource = self
    messageTextfield.delegate = self
    
    
    
    //TODO: Set yourself as the delegate of the text field here:
    
    
    
    //TODO: Set the tapGesture here:
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
    messageTableView.addGestureRecognizer(tapGesture)
    
    //TODO: Register your MessageCell.xib file here:
    messageTableView.register(UINib(nibName:"MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
    configureTableView()
    retrieveMessages()
    messageTableView.separatorStyle = .none
  }
  
  ///////////////////////////////////////////
  
  //MARK: - TableView DataSource Methods
  
  
  
  
  
  //TODO: Declare cellForRowAtIndexPath here:
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell",for: indexPath) as! CustomMessageCell
    cell.messageBody.text = self.messageArray[indexPath.row].messageBody
    cell.senderUsername.text  = self.messageArray[indexPath.row].sender
    cell.avatarImageView.image = UIImage(named: "egg")
    
    if cell.senderUsername.text == Auth.auth().currentUser?.email as! String {
      cell.avatarImageView.backgroundColor = UIColor.flatMint()
      cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
    } else {
      cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
      cell.messageBackground.backgroundColor = UIColor.flatGray()
      
    }
    return cell
    
  }
  
  
  //TODO: Declare numberOfRowsInSection here:
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messageArray.count
  }
  
  
  //TODO: Declare tableViewTapped here:
  @objc func tableViewTapped() {
    
    messageTextfield.endEditing(true)
  }
  
  
  //TODO: Declare configureTableView here:
  
  func configureTableView() {
    UIView.animate(withDuration: 0.5) {
      self.messageTableView.rowHeight = UITableViewAutomaticDimension
      self.messageTableView.estimatedRowHeight  = 120
    }
  }
  
  ///////////////////////////////////////////
  
  //MARK:- TextField Delegate Methods
  
  
  
  
  //TODO: Declare textFieldDidBeginEditing here:
  func textFieldDidBeginEditing(_ textField: UITextField) {
    UIView.animate(withDuration: 0.5) {
      self.heightConstraint.constant = 308
      self.view.layoutIfNeeded()
    }
  }
  
  
  
  //TODO: Declare textFieldDidEndEditing here:
  func textFieldDidEndEditing(_ textField: UITextField) {
    UIView.animate(withDuration: 0.5) {
      self.heightConstraint.constant = 50
      self.view.layoutIfNeeded()
    }
  }
  
  
  
  
  //MARK: - Send & Recieve from Firebase  
  @IBAction func sendPressed(_ sender: AnyObject) {
    
    messageTextfield.endEditing(true)
    messageTextfield.isEnabled = false
    sendButton.isEnabled = false
    //TODO: Send the message to Firebase and save it in our database
    let messagesDB = Database.database().reference().child("messages")
    let messageDict = ["Sender": Auth.auth().currentUser?.email, "MessageBody":messageTextfield.text!]
    messagesDB.childByAutoId().setValue(messageDict) { (error, ref) in
      
      if error != nil {
        print(error)
      } else {
        print("Message Saved Succesfully")
        self.messageTextfield.isEnabled = true
        self.sendButton.isEnabled = true
        self.messageTextfield.text = ""
        
      }
      
    }
    
  }
  
  //TODO: Create the retrieveMessages method here:
  func retrieveMessages() {
    
    let messageDB = Database.database().reference().child("messages")
    messageDB.observe(.childAdded) { (snapshot) in
      let snapshotValue = snapshot.value as! Dictionary<String, String>
      let text = snapshotValue["MessageBody"] as! String
      let sender = snapshotValue["Sender"] as! String
      let message = Message()
      message.messageBody = text
      message.sender = sender
      self.messageArray.append(message)
      self.configureTableView()
      self.messageTableView.reloadData()
      
    }
    
  }
  
  
  
  
  
  @IBAction func logOutPressed(_ sender: AnyObject) {
    
    //TODO: Log out the user and send them back to WelcomeViewController
    do{
      try Auth.auth().signOut()
      navigationController?.popToRootViewController(animated: true)
    } catch {
      print("error, there was a problem signing out")
    }
    
  }
  
  
  
}
