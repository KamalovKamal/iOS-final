import UIKit

class SearchViewController: UIViewController {

    // Убедись, что кружочки слева от этих строчек закрашены (подключены к Storyboard)
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    private var tracks: [Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        // Настройка спиннера (чтобы он исчезал, когда не крутится)
        activityIndicator.hidesWhenStopped = true
    }
}

// MARK: - Search Logic
extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        
        // 1. Скрываем клавиатуру сразу
        searchBar.resignFirstResponder()
        
        // 2. Включаем спиннер перед запросом
        activityIndicator.startAnimating()
        
        // Опционально: можно сделать таблицу чуть прозрачной, пока грузится
        tableView.alpha = 0.5

        // 3. Делаем запрос (добавил [weak self] для безопасности)
        NetworkService.shared.searchTracks(query: text) { [weak self] tracks in
            
            // Проверяем, что экран еще существует
            guard let self = self else { return }
            
            // 4. Обновляем UI ВСЕГДА в главном потоке
            DispatchQueue.main.async {
                self.tracks = tracks
                
                // Выключаем спиннер
                self.activityIndicator.stopAnimating()
                
                // Возвращаем прозрачность и обновляем данные
                self.tableView.alpha = 1.0
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - TableView Logic
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath)
        let track = tracks[indexPath.row]

        cell.textLabel?.text = track.title
        cell.detailTextLabel?.text = track.artist

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        // Снимаем выделение (серый фон) после нажатия
        tableView.deselectRow(at: indexPath, animated: true)

        let vc = storyboard?.instantiateViewController(
            identifier: "PlayerViewController"
        ) as! PlayerViewController

        vc.track = tracks[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // НОВОЕ: Скрываем клавиатуру при скролле ленты
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}
