//
//  ContentView.swift
//  CraveCrusher_2
//
//  Created by Michael Zhou on 1/30/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("Home", systemImage: "list.dash")
                }
            
            MenuView()
                .tabItem {
                    Label("Games", systemImage: "square.and.pencil")
                }
        }
    }
}

#Preview {
    ContentView()
}
