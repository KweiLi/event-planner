//
//  FirebaseAPI.swift
//  AppPlanner
//
//  Created by Kun Chen on 2023-09-21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseAPIManager: ObservableObject {
    
    private var db: Firestore
    
    @Published private var events:[Event] = []
    
    init(){
        db = Firestore.firestore()
    }

    func writeEvent(event: Event) async throws {
        do {
            _ = try db.collection("events").addDocument(from: event)
            print("Document has been saved")
        } catch {
            print(error.localizedDescription)
            throw CustomizedError.FireStoreWriteError
        }
    }
    
    func fetchEvent() {
        db.collection("events").getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.events = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Event.self)
                } ?? []
            }
        }
    }

}
