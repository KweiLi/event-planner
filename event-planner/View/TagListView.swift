//
//  TagListView.swift
//  AppPlanner
//
//  Created by Kun Chen on 2023-08-09.
//

import SwiftUI
import TagLayoutView

struct TagListView: View {
    var tags: [String]
    @Binding var searchKey:String
    var body: some View {
        TagView(tags: self.tags, selectedTag: $searchKey)
    }
}

struct TagListView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(LocationManager())
    }
}
