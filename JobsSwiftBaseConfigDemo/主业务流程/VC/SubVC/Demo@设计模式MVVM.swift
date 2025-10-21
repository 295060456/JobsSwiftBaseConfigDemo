// MARK: - MVVMDemo.swift
import UIKit

// ========== Model ==========
struct MVVMUser: Decodable { let id: String; let name: String }

// ========== Repository ==========
protocol MVVMUserRepository { func users() async throws -> [MVVMUser] }

final class MVVMMockUserRepo: MVVMUserRepository {
    func users() async throws -> [MVVMUser] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return [.init(id: "1", name: "Alice"),
                .init(id: "2", name: "Bob"),
                .init(id: "3", name: "Charlie")]
    }
}

// ========== ViewState ==========
enum MVVMUserListState {
    case loading
    case content([MVVMUser])
    case error(String)
}

// ========== ViewModel ==========
@MainActor
final class MVVMUserListViewModel {
    private let repo: MVVMUserRepository
    var onStateChange: ((MVVMUserListState) -> Void)?

    init(repo: MVVMUserRepository) { self.repo = repo }

    func load() {
        onStateChange?(.loading)
        Task { [weak self] in
            guard let self else { return }
            do {
                let list = try await repo.users()
                onStateChange?(.content(list))
            } catch {
                onStateChange?(.error(error.localizedDescription))
            }
        }
    }
}

// ========== ViewController ==========
final class MVVMUserListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let vm: MVVMUserListViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var data: [MVVMUser] = []

    init(vm: MVVMUserListViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Users (MVVM)"
        view.backgroundColor = .systemBackground
        tableView.dataSource = self; tableView.delegate = self
        view.addSubview(tableView); tableView.frame = view.bounds

        vm.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loading:
                self.navigationItem.prompt = "Loading..."
            case .content(let list):
                self.navigationItem.prompt = nil
                self.data = list
                self.tableView.reloadData()
            case .error(let msg):
                self.navigationItem.prompt = nil
                let ac = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        }
        vm.load()
    }

    // UITableView
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { data.count }
    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let c = tv.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let u = data[ip.row]
        c.textLabel?.text = u.name
        c.detailTextLabel?.text = "ID: \(u.id)"
        return c
    }
    func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
        let u = data[ip.row]
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "Detail \(u.name)"
        navigationController?.pushViewController(vc, animated: true)
    }
}

// ========== Builder ==========
enum MVVMBuilder {
    @MainActor
    static func build() -> UIViewController {
        let vm = MVVMUserListViewModel(repo: MVVMMockUserRepo())
        return MVVMUserListVC(vm: vm)
    }
}
