//
//  Persistence.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 20/04/2023.
//

import CoreData

class Persistence {
    static let shared = Persistence()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext

    init() {
        container = NSPersistentContainer(name: "ChatGPTApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // on error
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
    }
    
    func deleteAllEntities() {
        deleteAllEntities(ofType: "EChat")
        deleteAllEntities(ofType: "EChatMsg")
    }
    
    private func deleteAllEntities(ofType type: String) {
        let context = Persistence.shared.context
        let coordinator = context.persistentStoreCoordinator

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: type)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try coordinator?.execute(deleteRequest, with: context)
            context.reset() // reset the context to get rid of the cached values
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    func newChat() -> EChat {
        let emptyChat = EChat(context: context)
        emptyChat.messages = NSSet(array: [])
        emptyChat.model = "gpt-3.5-turbo"
        emptyChat.name = "Empty chat"
        emptyChat.pinned = false
        
        context.insert(emptyChat)
        saveContext()
        
        return emptyChat
    }
    
    func fetchChats() -> [EChat] {
        let req = EChat.fetchRequest()
        if let chats = try? context.fetch(req), !chats.isEmpty {
            return chats
        }
        
        let emptyChat = newChat()
        return [emptyChat]
    }
    
    func delete(chat: EChat) {
        context.delete(chat)
        saveContext()
    }

    func saveContext() {
        let ctx = container.viewContext
        if !ctx.hasChanges {
            return
        }
        
        do {
            try ctx.save()
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func onError(error: NSError) {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
    }
}
