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
    @State private var lookAroundScence: MKLookAroundScene?
    @State private var route: MKRoute?
    
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
    
    private func requestCalculateDirections() async {
        route = nil
        if let selectedMapItem {
            guard let userLocation = locationManager.manager.location else {
                return
            }
            let startMapItem = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
            
            self.route = await calculateDirections(from: startMapItem, to: selectedMapItem)
        }
    }
    
    var body: some View {
        ZStack {
            Map(position: $position, selection: $selectedMapItem) {
                ForEach(mapItems, id: \.self) { mapItem in
                    Marker(item: mapItem)
                }
                
                if let route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
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
                } else {
                    displayMode = .list
                }
            })
            .sheet(isPresented: .constant(true)) {
                VStack {
                    switch displayMode {
                    case .list:
                        SearchBarView(search: $query, isSearching: $isSearching)
                        PlaceListView(mapItems: self.mapItems, selectedMapItem: $selectedMapItem)
                    case .detail:
                        SelectedPlaceDetailView(mapItem: $selectedMapItem)
                            .padding()
                        if selectedDetent == .medium || selectedDetent == .large {
                            
                            if let selectedMapItem {
                                ActionButtons(mapItem: selectedMapItem)
                                    .padding(.leading)
                                    .padding(.bottom)
                            }
                            
                            LookAroundPreview(initialScene: lookAroundScence)
                        }
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
        .task(id: selectedMapItem) {
            lookAroundScence = nil
            route = nil
            if let selectedMapItem {
                let request = MKLookAroundSceneRequest(mapItem: selectedMapItem)
                lookAroundScence = try? await request.scene
                await requestCalculateDirections()
            }
        }
    }
}

#Preview {
    ContentView()
}

//Task closure does not cancel when View disappear >> Use task modifier
