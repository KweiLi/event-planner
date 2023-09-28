//
//  event_plannerApp.swift
//  event-planner
//
//  Created by Kun Chen on 2023-09-28.
//

import SwiftUI
import Firebase


@main
struct event_plannerApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MapView()
        }
    }
}
