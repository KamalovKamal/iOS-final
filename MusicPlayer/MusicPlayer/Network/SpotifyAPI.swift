import Foundation

final class NetworkService {

    static let shared = NetworkService()

    func searchTracks(query: String, completion: @escaping ([Track]) -> Void) {
        
        // 1. Используем iTunes API (оно бесплатное и надежное)
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?term=\(encodedQuery)&media=music&entity=song&limit=20") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let results = json?["results"] as? [[String: Any]] ?? []

                var tracks: [Track] = []

                for item in results {
                    // Парсинг под iTunes формат
                    let title = item["trackName"] as? String ?? ""
                    let artist = item["artistName"] as? String ?? ""
                    let duration = item["trackTimeMillis"] as? Int ?? 0
                    
                    // iTunes ВСЕГДА дает previewUrl
                    let previewString = item["previewUrl"] as? String
                    let previewURL = previewString != nil ? URL(string: previewString!) : nil
                    
                    // Картинка (берем качество получше, меняем 100x100 на 600x600 в ссылке)
                    let imageString = (item["artworkUrl100"] as? String)?.replacingOccurrences(of: "100x100", with: "600x600")
                    let imageURL = imageString != nil ? URL(string: imageString!) : nil

                    let track = Track(
                        title: title,
                        artist: artist,
                        duration: duration,
                        previewURL: previewURL,
                        imageURL: imageURL
                    )
                    tracks.append(track)
                }

                DispatchQueue.main.async {
                    completion(tracks)
                }

            } catch {
                print("Error parsing: \(error)")
            }
        }.resume()
    }
}
