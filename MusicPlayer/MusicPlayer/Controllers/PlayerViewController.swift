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
    @IBOutlet weak var timeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        timer?.invalidate()
    }

    func setupUI() {
        titleLabel.text = track?.title
        artistLabel.text = track?.artist
        timeLabel.text = "00:00"

        // Убираем любой текст с кнопки, чтобы остались только иконки
        playPauseButton.setTitle("", for: .normal)
        
        // (Опционально) Делаем иконки побольше
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        playPauseButton.setPreferredSymbolConfiguration(config, forImageIn: .normal)

        if let imageURL = track?.imageURL {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: imageURL) {
                    DispatchQueue.main.async {
                        self.albumImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }

    func setupPlayer() {
        guard let previewURL = track?.previewURL else {
            // Если превью нет, возвращаем текст, чтобы было понятно
            playPauseButton.setTitle("No Preview", for: .normal)
            playPauseButton.setImage(nil, for: .normal) // Убираем иконку
            playPauseButton.isEnabled = false
            return
        }

        let playerItem = AVPlayerItem(url: previewURL)
        player = AVPlayer(playerItem: playerItem)
        
        // Автозапуск -> Ставим иконку Паузы
        player?.play()
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)

        progressSlider.maximumValue = 30.0
        progressSlider.value = 0
        
        startSliderTimer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = player else { return }
        
        if player.timeControlStatus == .playing {
            // Ставим на паузу -> Показываем иконку Play
            player.pause()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            // Включаем -> Показываем иконку Pause
            player.play()
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        guard let player = player else { return }
        let time = CMTime(seconds: Double(sender.value), preferredTimescale: 600)
        player.seek(to: time)
    }

    func startSliderTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            
            let currentTime = player.currentTime().seconds
            self.progressSlider.value = Float(currentTime)
            self.timeLabel.text = self.formatTime(currentTime)
        }
    }
    
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @objc func playerDidFinishPlaying() {
        // Трек закончился -> Показываем иконку Play
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        player?.seek(to: .zero)
        progressSlider.value = 0
        timeLabel.text = "00:00"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
