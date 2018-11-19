import UIKit

// Displays GitHub repo search bar in table view section header and open pull requests in cells
class PullRequestsTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    // Create custom table view under navigation bar
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        [tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
         tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
         tableView.heightAnchor.constraint(equalTo: view.heightAnchor)
         ].forEach { $0.isActive = true }

        return tableView
    }()
    
    // Progress indicator
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.color = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        [spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)].forEach { $0.isActive = true }
        
        return spinner
    }()
    
    var pullRequests: [GitHubApi.PullRequest] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        view.backgroundColor = .clear
        setupNavBar()
        setupTableView()
        dismissKeyboardWhenTouchOutside()
    }
    
    private func setupNavBar()
    {
        navigationItem.title = "Open Pull Requests"
    }
    
    private func setupTableView()
    {
        tableView.register(PullRequestsTableViewCell.self,
                           forCellReuseIdentifier: PullRequestsTableViewCell.reuseId())
        
        tableView.backgroundColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1).withAlphaComponent(0.8)
        tableView.separatorColor = #colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)
        tableView.showsHorizontalScrollIndicator = false
        tableView.sectionHeaderHeight = view.frame.height * 0.1
        
        // Adjust bottom content inset to include section header height so that last cell will be fully visible when scrolling
        var newContentInset = tableView.contentInset
        newContentInset.bottom = tableView.contentInset.bottom + tableView.sectionHeaderHeight
        tableView.contentInset = newContentInset

        // Fill empty space
        tableView.tableFooterView = UIView()
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        return pullRequests.count
    }
    
    let rowsPerPortraitScreen: CGFloat = 6
    let rowsPerLandscapeScreen: CGFloat = 4

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return (tableView.frame.height - tableView.sectionHeaderHeight - view.safeAreaInsets.top) / (UIDevice.current.isPortrait() ? rowsPerPortraitScreen : rowsPerLandscapeScreen)
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: PullRequestsTableViewCell.reuseId(),
                                                 for: indexPath) as! PullRequestsTableViewCell
        
        guard indexPath.row < pullRequests.count else { return cell }
        
        cell.pullRequest = pullRequests[indexPath.row]
        return cell
    }

    // MARK: - UITableViewDelegate
    
    lazy var repoSearchBar: UIView = {
        // Create container view to customize search bar background color
        let container = UIView()
        container.backgroundColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
        
        // Set up search bar and add to container
        let searchBar = UISearchBar()
        searchBar.enablesReturnKeyAutomatically = true
        // Remove search bar background so that container background color is visible
        searchBar.removeBgView()
        searchBar.placeholder = "e.g. \"magicalpanda/MagicalRecord\""
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(searchBar)
        [searchBar.widthAnchor.constraint(equalTo: container.widthAnchor),
         searchBar.heightAnchor.constraint(equalTo: container.heightAnchor),
         searchBar.centerXAnchor.constraint(equalTo: container.centerXAnchor),
         searchBar.centerYAnchor.constraint(equalTo: container.centerYAnchor)].forEach { $0.isActive = true }
        
        return container
    }()
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView?
    {
        return repoSearchBar
    }
    
    // Flag to handle when cells are tapped multiple times at once
    var rowSelected = false
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath)
    {
        guard !rowSelected,
            let cell = tableView.cellForRow(at: indexPath) as? PullRequestsTableViewCell,
            let pullReq = cell.pullRequest else { return }
        
        // Display commits diff for pull request
        spinner.startAnimating()
        rowSelected = true
        GitHubManager.fetchCommitsDiff(for: pullReq) {
            [weak self] prDiff, error in
            
            // Failed to fetch diff
            if let err = error
            {
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    let alert = UIAlertController(title: "GitHub Error", message: err, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self?.present(alert, animated: true, completion: nil)
                    self?.rowSelected = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.spinner.stopAnimating()
                let diffVC = PullRequestDiffVC()
                diffVC.pullReq = pullReq
                diffVC.diffs = prDiff
                self?.navigationController?.pushViewController(diffVC, animated: true)
                self?.rowSelected = false
            }
        }
    }

}

extension PullRequestsTableVC: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        guard let repo = searchBar.text,
            repo.count > 0 else { return }
        
        // Fetch repo pull requests from GitHub
        spinner.startAnimating()
        GitHubManager.fetchPullRequests(for: repo) {
            [weak self] (pullReqs: [GitHubApi.PullRequest]?, response, error) in
        
            DispatchQueue.main.async { self?.spinner.stopAnimating() }
            
            if let response = response,
                response.statusCode == GitHubManager.httpStatus.notFound.rawValue
            {
                // Aert user that repo was not found
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: repo + " repo not found on GitHub", message: "", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self?.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            guard let pullReqs = pullReqs else { return }
            
            // Display pull requests in table view
            self?.pullRequests = pullReqs
            DispatchQueue.main.async {
                self?.tableView.reloadSections([0], with: .bottom)
            }
        }
        
        searchBar.endEditing(true)
    }
}
