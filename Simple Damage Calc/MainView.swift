//
//  MainView.swift
//  Simple Damage Calc
//
//  Created by Jesse Joseph on 19/11/21.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ContentView(compareDamage: Binding.constant(-1), compareAvgDamage: Binding.constant(-1))
                .tabItem {
                    Label("Damage", systemImage: "square.and.pencil")
                }
            
            PrimogemView()
                .tabItem {
                    Label("Primos", systemImage: "star")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
