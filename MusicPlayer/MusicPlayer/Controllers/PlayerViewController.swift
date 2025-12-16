import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    var track: Track?
    var player: AVPlayer?
    var timer: Timer?
    
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Название и артист
        titleLabel.text = track?.title
        artistLabel.text = track?.artist

        // Обложка
        if let imageURL = track?.imageURL {
            URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.albumImageView.image = UIImage(data: data)
                }
            }.resume()
        }

        // Preview
        if let previewURL = track?.previewURL {
            player = AVPlayer(url: previewURL)
            progressSlider.maximumValue = 30
            progressSlider.value = 0
            startSliderTimer()
        } else {
            playPauseButton.setTitle("No preview", for: .normal)
            playPauseButton.isEnabled = false
        }
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = player else { return }

        if player.timeControlStatus == .playing {
            player.pause()
            sender.setTitle("Play", for: .normal)
        } else {
            player.play()
            sender.setTitle("Pause", for: .normal)
        }
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: Double(sender.value), preferredTimescale: 1)
        player.seek(to: targetTime)
    }

    func startSliderTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let currentTime = self.player?.currentTime().seconds {
                self.progressSlider.value = Float(currentTime)
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}
