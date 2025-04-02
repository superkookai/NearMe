//
//  ActionButtons.swift
//  NearMe
//
//  Created by Weerawut Chaiyasomboon on 02/04/2568.
//

import SwiftUI
import MapKit

struct ActionButtons: View {
    let mapItem: MKMapItem
    
    var body: some View {
        HStack {
            if let phone = mapItem.phoneNumber {
                Button {
                    
                    let numericPhoneNumber = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    makeCall(phoneNumber: numericPhoneNumber)
                    
                } label: {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call")
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Button {
                MKMapItem.openMaps(with: [mapItem])
            } label: {
                HStack {
                    Image(systemName: "car.circle.fill")
                    Text("Take me there")
                }
            }
            .buttonStyle(.bordered)
            .tint(.green)
            
            Spacer()
        }
    }
}

#Preview {
    ActionButtons(mapItem: PreviewData.apple)
}
