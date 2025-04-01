import SwiftUI

struct AsyncImageView: View {
    let url: String
    let aspectRatio: CGFloat = 16/9
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .frame(maxHeight: 200)
                    .clipped()
                    .cornerRadius(8)
            case .failure(_):
                Image(systemName: "photo.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
            @unknown default:
                EmptyView()
            }
        }
    }
} 