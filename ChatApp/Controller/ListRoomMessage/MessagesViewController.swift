//
//  MessagesViewController.swift
//  ChatApp
//
//  Created by Dan on 7/22/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import ProgressHUD

class MessagesViewController: UIViewController {
    //MARK: IBOulet
    @IBOutlet weak var messageCollectionView: UICollectionView!
    @IBOutlet weak var messagesTableView: UITableView!
    
    var users = [User]()
    var userchat = [UserChat]()
    let uid = Auth.auth().currentUser?.uid ?? ""
    var isExist: Bool = false
    var lastmessage = [LastMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViewCell()
        setupCollectionViewCell()
        fetchUser()
        getThreadChatRef()
        getRefInListenerMessage()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setupUI() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Strings.MessageViewController.logOut, style: .plain, target: self, action: #selector(handleLogout))
        self.navigationItem.title = Strings.MessageViewController.titleMsg
        self.messagesTableView.separatorStyle = .none
        self.messagesTableView.reloadData()
        self.messageCollectionView.reloadData()
    }
    
    //MARK: IBAction
    @objc func handleLogout() {
        Firestores.documentUser.document(uid).updateData(["isOnline": false])
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func fetchUser() {
        self.users.removeAll()
        Firestores.documentUser.getDocuments { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            }
            guard let snapshot = snapshot else { return }
            for document in snapshot.documents {
                let data = document.data()
                let id = data["id"] as? String
                if id != self.uid {
                    guard let user = try? DictionaryDecoder().decode(User.self, from: data) else { return }
                    self.users.append(user)
                }
            }
            DispatchQueue.main.async {
                self.messageCollectionView.reloadData()
            }
        }
    }
    
    func getThreadChatRef() {
        ProgressHUD.show()
        Firestores.documentUser.document(uid).collection(Strings.groupCollection).order(by: Strings.timestamp, descending: true).getDocuments { (chatGroup, err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                var usergroupchat = [UserGroupChat]()
                for document in chatGroup!.documents {
                    let data = document.data()
                    guard let user = try? DictionaryDecoder().decode(UserGroupChat.self, from: data) else { return }
                    usergroupchat.append(user)
                }
                self.fetchMessage(usergroupchat: usergroupchat)
            }
            ProgressHUD.dismiss()
        }
    }
    
    func fetchMessage(usergroupchat: [UserGroupChat]) {
        for user in usergroupchat {
            guard let ref = user.peerRef else { return }
            Firestores.documentThreads.document(ref).getDocument { (lastMessageChat, err) in
                if let err = err {
                    print(err.localizedDescription)
                }
                guard let data = lastMessageChat?.data() else { return }
                guard let lastMessage = try? DictionaryDecoder().decode(LastMessage.self, from: data) else { return }
                let userchat = UserChat(userGroupChat: user, lastMessageChat: lastMessage)
                self.userchat.append(userchat)
                DispatchQueue.main.async {
                    self.messagesTableView.reloadData()
                    self.listenLastmessage()
                }
            }
        }
    }
    
    
    func listenLastmessage() {
        for user in userchat {
            guard let ref = user.peerRef else { return }
            Firestores.documentThreads.document(ref).addSnapshotListener { (querySnapshot, err) in
                guard let snapshot = querySnapshot else { return }
                guard let data = snapshot.data() else { return }
                guard let lastmessage = try? DictionaryDecoder().decode(LastMessage.self, from: data) else { return }
                let peer_id = self.uid == lastmessage.uidA ? lastmessage.uidB : lastmessage.uidA
                if let index = self.userchat.firstIndex(where: {$0.peerId == peer_id}) {
                    print(index)
                    self.userchat[index].lastMessage = lastmessage.lastMessage
                    self.userchat[index].timestamp = lastmessage.timestamp
                    let unread = self.uid == lastmessage.uidA ? lastmessage.unreadA : lastmessage.unreadB
                    self.userchat[index].unread = unread
                    DispatchQueue.main.async {
                        self.messagesTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func getRefInListenerMessage() {
        let timestamp: Double = NSDate().timeIntervalSince1970 as Double
        Firestores.documentUser.document(uid).collection(Strings.groupCollection).whereField(Strings.timestamp, isGreaterThan: timestamp).addSnapshotListener { (querySnapshot, err) in
            guard let snapshot = querySnapshot else { return }
            var usergroupchat = [UserGroupChat]()
            for document in snapshot.documents {
                let data = document.data()
                guard let user = try? DictionaryDecoder().decode(UserGroupChat.self, from: data) else { return }
                usergroupchat.append(user)
            }
            self.listenNewThreadsMessage(usergroupchat: usergroupchat)
        }
    }
    
    func listenNewThreadsMessage(usergroupchat: [UserGroupChat]) {
        for user in usergroupchat {
            guard let ref = user.peerRef else { return }
            Firestores.documentThreads.document(ref).addSnapshotListener { (querySnapshot, err) in
                guard let snapshot = querySnapshot else { return }
                guard let dataMessage = snapshot.data() else { return }
                guard let lastMessage = try? DictionaryDecoder().decode(LastMessage.self, from: dataMessage) else { return }
                let receiverID = self.uid == lastMessage.uidA ? lastMessage.uidB : lastMessage.uidA
                for userResult in self.userchat {
                    if userResult.peerId == receiverID {
                        self.isExist = true
                    }
                }
                let updateUserChat = self.userchat.first(where: { $0.peerId == receiverID })
                if self.isExist {
                    updateUserChat?.lastMessage = lastMessage.lastMessage
                    updateUserChat?.timestamp = lastMessage.timestamp
                    let unread = self.uid == lastMessage.uidA ? lastMessage.unreadA : lastMessage.unreadB
                    updateUserChat?.unread = unread
                    DispatchQueue.main.async {
                        self.messagesTableView.reloadData()
                    }
                } else {
                    let usermessage = UserChat(userGroupChat: user, lastMessageChat: lastMessage)
                    self.userchat.append(usermessage)
                    DispatchQueue.main.async {
                        self.messagesTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func getUser(user: UserChat) -> User {
        let user1 = User(id: user.peerId, name: user.name, profileImage: user.profileImage)
        user1.id = user.peerId
        user1.name = user.name
        user1.profileImage = user.profileImage
        return user1
    }
    
    func setupTableViewCell() {
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.register(UINib(nibName: MessagesTableViewCell.className, bundle: nil), forCellReuseIdentifier: MessagesTableViewCell.className)
    }
    
    func setupCollectionViewCell() {
        messageCollectionView.delegate = self
        messageCollectionView.dataSource = self
        messageCollectionView.collectionViewLayout = createLayout()
        messageCollectionView.register(UINib(nibName: UserCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: UserCollectionViewCell.className)
    }
}


extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userchat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messagesTableView.dequeueReusableCell(cell: MessagesTableViewCell.self, for: indexPath) { (tableViewCell) in
            let user = userchat[indexPath.row]
            tableViewCell.fillData(data: user)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MessagesChatViewController()
        let user = userchat[indexPath.row]
        vc.user = getUser(user: user) // user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension MessagesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = messageCollectionView.dequeueReuseableCell(cell: UserCollectionViewCell.self, for: indexPath) { (collectionViewCell) in
            let user = users[indexPath.row]
            collectionViewCell.fill(data: user)
        }
        ProgressHUD.dismiss()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MessagesChatViewController()
        let user1 = users[indexPath.row]
        vc.user = user1
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionNumber: Int, layoutEnviroment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/9), heightDimension: .absolute(100)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
        return layout
    }
}

