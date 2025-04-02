//
//  ContentView.swift
//  StellarTales
//
//  Created by Karthik Kottugumada on 3/31/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var astronomyService = AstronomyService()
    @State private var searchText = ""
    @State private var searchResults: [SpaceObject] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search celestial objects...", text: $searchText)
                        .font(.system(size: 16))
                        .onChange(of: searchText) { oldValue, newValue in
                            Task {
                                await performSearch(query: newValue)
                            }
                        }
                }
                .frame(height: 44)
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                if searchText.isEmpty {
                    // Show APOD when no search
                    APODView()
                } else if astronomyService.isLoading {
                    ProgressView()
                } else {
                    List(searchResults) { object in
                        NavigationLink(destination: CelestialObjectDetailView(object: object)) {
                            CelestialObjectRowView(object: object)
                        }
                    }
                }
            }
            .navigationTitle("Stellar Tales")
        }
    }
    
    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        do {
            searchResults = try await astronomyService.searchCelestialObjects(query: query)
        } catch {
            astronomyService.error = error.localizedDescription
        }
    }
}

struct CelestialObjectView: View {
    let object: SpaceObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Replace AsyncImage with our custom view
            AsyncImageView(url: object.imageUrl)
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(object.title)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(object.detailedDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                
                if !object.mythology.isEmpty {
                    Text("Mythology")
                        .font(.headline)
                        .padding(.top, 4)
                    Text(object.mythology)
                        .font(.body)
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct DefaultView: View {
    var body: some View {
        VStack {
            Image(systemName: "star.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Search for constellations,\nstars, or planets")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        Spacer()
    }
}

#Preview {
    ContentView()
}
