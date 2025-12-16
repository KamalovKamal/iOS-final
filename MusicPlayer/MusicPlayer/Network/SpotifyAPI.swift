import Foundation

final class SpotifyAPI {

    static let shared = SpotifyAPI()
    

    private let accessToken = "BQD3dDQ6HZjf26DARJqISkDlKUiMm1gDUVKXJQgvaPmevyv4QlprRjNN-7KOvPDpcaUa0M-g4Tk0iVZHQAzofJGsCbVsO-q1CH-TXGHJCbvt6wtgz0bBBczjNUGIUZh9Dw7PtC_-wQY"

    func searchTracks(query: String, completion: @escaping ([Track]) -> Void) {

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=track&limit=20"

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let tracksJSON = (json?["tracks"] as? [String: Any])?["items"] as? [[String: Any]] ?? []

                var result: [Track] = []

                for item in tracksJSON {

                    // Название
                    let title = item["name"] as? String ?? ""

                    // Длительность
                    let duration = item["duration_ms"] as? Int ?? 0

                    // Preview URL
                    let preview = item["preview_url"] as? String
                    let previewURL = preview != nil ? URL(string: preview!) : nil

                    // Артист
                    let artists = item["artists"] as? [[String: Any]]
                    let artist = artists?.first?["name"] as? String ?? ""

                    // Картинка
                    let album = item["album"] as? [String: Any]
                    let images = album?["images"] as? [[String: Any]]
                    let imageString = images?.first?["url"] as? String
                    let imageURL = imageString != nil ? URL(string: imageString!) : nil

                    let track = Track(
                        title: title,
                        artist: artist,
                        duration: duration,
                        previewURL: previewURL,
                        imageURL: imageURL
                    )

                    result.append(track)
                }

                DispatchQueue.main.async {
                    completion(result)
                }

            } catch {
                print("JSON parsing error:", error)
                
            }
        }.resume()
    }
}
