//
//  SearchOptionsView.swift
//  NearMe
//
//  Created by Weerawut Chaiyasomboon on 01/04/2568.
//

import SwiftUI

struct SearchOptionsView: View {
    let searchOptions =  ["Restaurants": "fork.knife", "Hotels": "bed.double.fill", "Coffee": "cup.and.saucer.fill", "Gas": "fuelpump.fill"]
    let onSelected: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(searchOptions.sorted(by: >), id: \.key) { key, value in
                    
                    Button {
                        onSelected(key)
                    } label: {
                        HStack {
                            Image(systemName: value)
                            Text(key)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 236/255, green: 240/255, blue: 241/255, opacity: 1.0))
                    .foregroundStyle(.black)
                    .padding(4)
                }
            }
        }
    }
}

#Preview {
    SearchOptionsView(onSelected: {_ in })
}
