import SwiftUI

struct CelestialObjectRowView: View {
    let object: SpaceObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(object.title)
                .font(.headline)
            Text(object.summary)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
    }
} 