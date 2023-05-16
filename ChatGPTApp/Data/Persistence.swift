//
//  Persistence.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 20/04/2023.
//

import FirebaseFirestore

class Persistence: ObservableObject {
    @Published private(set) var chats: [EChat] = []
    
    private var db: Firestore { get { Firestore.firestore() } }
    private var chatsCollection: CollectionReference { get { db.collection("chats") } }
    
    func fetchChats() {
        chatsCollection.addSnapshotListener { snapshot, error in
            guard self.checkErrors(snapshot, error: error) else {
                return
            }

            let chats = snapshot!.documents
                .compactMap { EChat.decode(from: $0.data()) }
            DispatchQueue.main.async {
                self.chats = chats
            }
        }
    }
    
    func add(chat: EChat) {
        DispatchQueue.main.async {
            self.chats.append(chat)
        }
        chatsCollection.addDocument(data: chat.encode()) { error in
            guard self.checkErrors(error: error) else {
                return
            }
            self.fetchChats()
        }
    }
    
    func update(chat: EChat) {
        chatsCollection.document(chat.id).setData(chat.encode(), merge: true) { error in
            guard self.checkErrors(error: error) else {
                return
            }
            self.fetchChats()
        }
    }
    
    func delete(chat: EChat) {
        chats.removeAll(where: { $0.id == chat.id })
        chatsCollection.document(chat.id).delete { error in
            guard self.checkErrors(error: error) else {
                return
            }
        }
    }
    
    func batchDelete(chats: [EChat]) {
    }
    
    private func checkErrors(_ obj: Any? = 1, error: Error?) -> Bool {
        if error != nil {
            print(error!)
            return false
        }
        
        guard let obj = obj else {
            print("snapshot was nil")
            return false
        }
        
        return true
    }
}
