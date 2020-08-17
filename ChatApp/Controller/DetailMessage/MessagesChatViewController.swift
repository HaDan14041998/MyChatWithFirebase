import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class MessagesChatViewController: UIViewController {
    //outlet
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var messagesChatTableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var user: User?
    var userchat: UserChat? 
    var messageChat = [Messages]()
    let uid = Auth.auth().currentUser?.uid ?? ""
    var loadingData = false
    var firstDocument: QueryDocumentSnapshot?
    var imageUploadInChat: UIImage? = nil
    var unread: Int = 0
    var isExist: Bool = false
    var isEndLoadMore: Bool = false
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchMessage()
        updateUnread()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.remove()
    }

    func setupUI() {
        chatTextField.setupChat()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        setupTableViewCell()
        self.title = user?.name
        spinner.isHidden = true
    }

    func setupTableViewCell() {
        messagesChatTableView.delegate = self
        messagesChatTableView.dataSource = self
        messagesChatTableView.register(UINib(nibName: MessageInComingChatCell.className, bundle: nil), forCellReuseIdentifier: MessageInComingChatCell.className)
        messagesChatTableView.register(UINib(nibName: MyChatCell.className, bundle: nil), forCellReuseIdentifier: MyChatCell.className)
        messagesChatTableView.separatorStyle = .none
    }
    
    
    func getThreadName(authenID: String, toID: String) -> String {
        let authen = authenID as NSString
        let checkResult = authen.compare(toID)
        if checkResult.rawValue == 1 {
            //check result neu = 1 thi authenID dang lon hon toID
            return toID + "-" + authenID
        } else {
            //check result neu = -1 thi authenID dang nho hon toID
            return authenID + "-" + toID
        }
    }   
    
    //MARK: IBAction
    
    @IBAction func sendMessages(_ sender: Any) {
        let timestamp: Double = NSDate().timeIntervalSince1970 as Double
        postDataMessageChat(timestamp: timestamp)
        postDataLastMessage(timestamp: timestamp)
        postDataUserChatGroup()
        guard let content = chatTextField.text, let toID = user?.id else { return }
        let chatMsg = Messages(content, fromID: uid, toID: toID, timeStamp: timestamp)
        messageChat.append(chatMsg)
        messagesChatTableView.reloadData()
        self.chatTextField.text = ""
        self.scrollBottomChat()
    }
    
    func fetchMessage() {
        let threadName = getThreadName(authenID: uid, toID: user?.id ?? "")
        Firestores.documentThreads.document(threadName).collection(Strings.messagesCollection).order(by: Strings.timeStamp, descending: false).limit(toLast: 20).getDocuments { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                guard let snapshot = snapshot else { return }
                self.isEndLoadMore = snapshot.count < 20
                for document in snapshot.documents {
                    let data = document.data()
                    guard let message = try? DictionaryDecoder().decode(Messages.self, from: data) else { return }
                    self.messageChat.append(message)    
                    DispatchQueue.main.async {
                        self.messagesChatTableView.reloadData()
                        self.scrollBottomChat()
                    }
                }
                self.firstDocument = snapshot.documents.first
                self.listenDetailChat()
            }
        }
    }
    
    func paginate() {
        let threadName = getThreadName(authenID: uid, toID: user?.id ?? "")
        guard let firstDocument = firstDocument else { return }
        Firestores.documentThreads.document(threadName).collection(Strings.messagesCollection).order(by: Strings.timeStamp).limit(toLast: 20).end(beforeDocument: firstDocument).getDocuments { (snapshot, err) in
            guard let snapshot = snapshot else { return }
            print(snapshot.count)
            for document in snapshot.documents.reversed() {
                let data = document.data()
                guard let message = try? DictionaryDecoder().decode(Messages.self, from: data) else { return }
                self.messageChat.insert(message, at: 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.reloadDataAndKeepOffset()
                    self.spinner.isHidden = true
                    self.loadingData = false
                }
            }
            self.firstDocument = snapshot.documents.first
        }
    }
    
    func listenDetailChat() {
        let threadName = getThreadName(authenID: uid, toID: user?.id ?? "")
        let timestamp: Double = NSDate().timeIntervalSince1970 as Double
        listener = Firestores.documentThreads.document(threadName).collection(Strings.messagesCollection).whereField(Strings.timeStamp, isGreaterThan: timestamp).addSnapshotListener { querysnapshot, err in
            guard let snapshot = querysnapshot else { return }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let data = diff.document.data()
                    guard let message = try? DictionaryDecoder().decode(Messages.self, from: data) else { return }
                    if self.user?.id == message.fromID {
                        self.messageChat.append(message)
                        self.updateUnread()
                        DispatchQueue.main.async {
                            self.messagesChatTableView.reloadData()
                            self.scrollBottomChat()
                        }
                    }
                }
            }
        }
    }
    
    func scrollBottomChat() {
        let row = self.messageChat.count - 1
        if row > 3 {
            self.messagesChatTableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .bottom, animated: false)
        }
    }
    
    func postDataMessageChat(timestamp: Double) {
        guard let content = chatTextField.text, let toID = user?.id else { return }
        let threadName = getThreadName(authenID: uid, toID: toID)
        let ref = Firestores.documentThreads.document(threadName).collection(Strings.messagesCollection).document()
        let messages = Messages(content, fromID: self.uid, toID: toID, timeStamp: timestamp)
        guard let dict = try? DictionaryEncoder().encode(messages) else { return }
        ref.setData(dict)
    }
    
    func postDataUserChatGroup() {
        guard let toID = user?.id, let name = user?.name, let profileImage = user?.profileImage else { return }
        let timestamp: Double = NSDate().timeIntervalSince1970 as Double
        let threadName = getThreadName(authenID: uid, toID: toID)
        let groupRef = Firestores.documentUser.document(uid).collection(Strings.groupCollection).document(toID)
        let groupReceiverRef = Firestores.documentUser.document(toID).collection(Strings.groupCollection).document(uid)
        let userchat = UserChat(name: name, profileImage: profileImage, peer_ref: threadName, timestamp: timestamp)
        guard let dict = try? DictionaryEncoder().encode(userchat) else { return }
        groupRef.setData(dict)
        Firestores.documentUser.whereField("id", isEqualTo: uid).getDocuments { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                for document in snapshot!.documents {
                    let data = document.data()
                    guard let user = try? DictionaryDecoder().decode(UserGroupChat.self, from: data) else { return }
                    let userchat1 = UserChat(name: user.name, profileImage: user.profileImage, peer_ref: threadName, timestamp: timestamp)
                    guard let dict1 = try? DictionaryEncoder().encode(userchat1) else { return }
                    groupReceiverRef.setData(dict1)
                }
            }
        }
    }
    
    func postDataLastMessage(timestamp: Double) {
        guard let toID = user?.id, let lastMessage = chatTextField.text else { return }
        let threadName = getThreadName(authenID: uid, toID: toID)
        let mesRef = Firestores.documentThreads.document(threadName)
        let lastmessage = LastMessage(lastMessage: lastMessage, timestamp: timestamp, uidA: toID, uidB: uid, unreadB: 0)
        guard let dict = try? DictionaryEncoder().encode(lastmessage) else { return }
        Firestores.documentUser.document(uid).collection(Strings.groupCollection).getDocuments { (snapshot, err) in
            guard let snapshot = snapshot else { return }
            for document in snapshot.documents {
                let id_group = document.documentID
                if id_group == toID {
                    self.isExist = true
                }
            }
        }
        if !self.isExist{
            let newmessage = LastMessage(lastMessage: lastMessage, timestamp: timestamp, uidA: toID, uidB: self.uid, unreadA: 1, unreadB: 0)
            guard let dictNewMessage = try? DictionaryEncoder().encode(newmessage) else { return }
            mesRef.setData(dictNewMessage)
        } else {
            mesRef.updateData(dict)
            mesRef.updateData(["unreadA": FieldValue.increment(Int64(1))])
        }
    }

    func updateUnread() {
        let threadName = getThreadName(authenID: uid, toID: user?.id ?? "")
        Firestores.documentThreads.getDocuments { (result, err) in
            guard let result = result else { return }
            for document in result.documents {
                let data = document.data()
                guard let message = try? DictionaryDecoder().decode(LastMessage.self, from: data) else { return }
                if message.uidA == self.uid {
                    Firestores.documentThreads.document(threadName).updateData(["unreadA": 0])
                }
            }
        }
    }
    
}

extension MessagesChatViewController: UITableViewDelegate {
    
}

extension MessagesChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageChat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messages = messageChat[indexPath.row]
        if uid == messages.fromID {
            return messagesChatTableView.dequeueReusableCell(cell: MyChatCell.self, for: indexPath) { (tableViewCell) in
                tableViewCell.fill(messages)
            }
        } else {
            return messagesChatTableView.dequeueReusableCell(cell: MessageInComingChatCell.self, for: indexPath) { (tableViewCell) in
                tableViewCell.fillData(data: messages)
            }
        }
    }

}

extension MessagesChatViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            if !loadingData && !isEndLoadMore {
                spinner.startAnimating()
                spinner.isHidden = false
                paginate()
                self.loadingData = true
            } else {
                spinner.isHidden = true
            }
        }
    }
    
    func reloadDataAndKeepOffset() {
        let contentOffSet = messagesChatTableView.contentOffset
        //stop scrolling
        messagesChatTableView.setContentOffset(contentOffSet, animated: false)
        // calculate the offset and reloadData
        let beforeContentSize = messagesChatTableView.contentSize
        messagesChatTableView.reloadData()
        messagesChatTableView.layoutIfNeeded()
        let afterContentSize = messagesChatTableView.contentSize
        // reset the contentOffset after data is updated
        let newOffSet = CGPoint(x: contentOffSet.x + (afterContentSize.width - beforeContentSize.width), y: contentOffSet.y + (afterContentSize.height - beforeContentSize.height))
        messagesChatTableView.setContentOffset(newOffSet, animated: false)
    }
    
}
