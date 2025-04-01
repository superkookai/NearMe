//
//  ContentView.swift
//  NearMe
//
//  Created by Weerawut Chaiyasomboon on 01/04/2568.
//

import SwiftUI
import MapKit

enum DisplayMode {
    case list, detail
}

struct ContentView: View {
    @State private var query: String = ""
    @State private var selectedDetent: PresentationDetent = .fraction(0.15)
    @State private var locationManager = LocationManager.shared
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isSearching: Bool = false
    @State private var mapItems: [MKMapItem] = []
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var selectedMapItem: MKMapItem?
    @State private var displayMode: DisplayMode = .list
    
    private func search() async {
        do {
            self.mapItems = try await performSearch(searchTerm: query, visibleRegion: self.visibleRegion)
            print(self.mapItems)
            isSearching = false
        } catch {
            self.mapItems = []
            isSearching = false
            print("Error search: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        ZStack {
            Map(position: $position, selection: $selectedMapItem) {
                ForEach(mapItems, id: \.self) { mapItem in
                    Marker(item: mapItem)
                }
                
                UserAnnotation()
            }
            .onChange(of: locationManager.region, { _, _ in
                withAnimation {
                    self.position = .region(locationManager.region)
                }
            })
            .onChange(of: self.selectedMapItem, { _, _ in
                if let _ = self.selectedMapItem {
                    displayMode = .detail
                    selectedDetent = .large
                } else {
                    displayMode = .list
                    selectedDetent = .medium
                }
            })
            .sheet(isPresented: .constant(true)) {
                VStack {
                    switch displayMode {
                    case .list:
                        SearchBarView(search: $query, isSearching: $isSearching)
                        PlaceListView(mapItems: self.mapItems)
                    case .detail:
                        SelectedPlaceDetailView(mapItem: $selectedMapItem)
                            .padding()
                    }
                }
                .presentationDetents([.fraction(0.15), .medium, .large], selection: $selectedDetent)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            }
            .onMapCameraChange { context in
                self.visibleRegion = context.region
            }
        }
        .task(id: isSearching) {
            if isSearching {
                await search()
            }
        }
    }
}

#Preview {
    ContentView()
}
