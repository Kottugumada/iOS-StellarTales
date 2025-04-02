import SwiftUI
import WebKit

struct APODView: View {
    @StateObject private var viewModel = APODViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .frame(height: 200)
            } else if let apod = viewModel.apodData {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
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
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .frame(height: 200)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(apod.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(apod.date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let copyright = apod.copyright {
                                Text("© \(copyright)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(apod.explanation)
                                .font(.body)
                                .padding(.top, 4)
                        }
                    }
                    .padding()
                }
                .refreshable {
                    print("Refreshing APOD...")  // Debug print
                    await viewModel.fetchAPOD()
                }
            } else if let error = viewModel.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(error)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        Task {
                            await viewModel.fetchAPOD()
                        }
                    }
                }
                .padding()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Task {
                    await viewModel.fetchAPOD()
                }
            }
        }
        .task {
            await viewModel.fetchAPOD()
        }
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