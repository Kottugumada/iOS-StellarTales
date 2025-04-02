import SwiftUI
import WebKit

struct APODView: View {
    @StateObject private var viewModel = APODViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isLoading {
                ProgressView()
                    .frame(height: 200)
            } else if let apod = viewModel.apodData {
                AsyncImage(url: URL(string: apod.url)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                    case .failure(_):
                        FallbackView()
                    @unknown default:
                        FallbackView()
                    }
                }
                .frame(maxHeight: 300)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(apod.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(apod.date)
                            .font(.subheadline)
                        if let copyright = apod.copyright {
                            Spacer()
                            Text("© \(copyright)")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.secondary)
                    
                    Text(apod.explanation)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding()
            } else if let error = viewModel.error {
                ErrorView(message: error)
                    .onTapGesture {
                        viewModel.fetchAPOD()
                    }
            }
        }
        .padding()
    }
}

// Video WebView
struct VideoView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

struct ImageLoadingError: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("Unable to load media")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            Text(message)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct FallbackView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            Text("Loading Astronomy Picture")
                .font(.headline)
            Text("Finding the best available image...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    APODView()
} 