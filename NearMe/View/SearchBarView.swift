//
//  SearchBarView.swift
//  NearMe
//
//  Created by Weerawut Chaiyasomboon on 01/04/2568.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var search: String
    @Binding var isSearching: Bool
    
    var body: some View {
        VStack(spacing: -10) {
            TextField("Search", text: $search)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onSubmit {
                    isSearching = true
                }
            
            SearchOptionsView { searchItem in
                self.search = searchItem
                isSearching = true
            }
            .padding(.leading, 10)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    SearchBarView(search: .constant("Coffee"), isSearching: .constant(true))
}
