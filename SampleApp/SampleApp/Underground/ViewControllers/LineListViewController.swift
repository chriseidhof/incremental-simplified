import Foundation
import Incremental
import Resin
import UIKit

class LineListViewController: UITableViewController {
    let viewModel: I<ViewModel>

    private var dataSource: DataSource!
    
    init(viewModel: I<ViewModel>) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        dataSource = DataSource(tableView: tableView)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        whileVisible.do { (owner: LineListViewController) in
            [
                owner.bind(keyPath: \.title, to: owner.viewModel[\.line]),
                owner.bind(keyPath: \.dataSource.stations, to: owner.viewModel[\.stations]),
            ]
        }
    }
    
}

extension LineListViewController {
    class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
        var stations: [String] = [] {
            didSet {
                tableView?.reloadData()
            }
        }
        
        weak var tableView: UITableView?
        
        init(tableView: UITableView) {
            self.tableView = tableView
            super.init()
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return stations.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = stations[indexPath.row]
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let name = stations[indexPath.row]
            let identifier = StationDetailViewController.PresentationIdentifier(name: name)
            
            tableView.dispatch(ImplicitPresentationAction.push(identifier))
        }
    }
}

extension LineListViewController {
    struct ViewModel: Resin.ViewModel, DefaultInit  {
        var line: String = ""
        var stations: [String] = []
        var isStale = false
    }
}

extension LineListViewController {
    struct PresentationIdentifier: Resin.PresentationIdentifier {
        public var line: String

        public init(line: String) {
            self.line = line
        }
    }
    
    static var presentationRoute: PresentationRoute<PresentationIdentifier, StationsState, LineListViewController> {
        return PresentationRoute { identifier, store in
            let vm = store.state.map { stationState -> ViewModel in
                let stations = stationState.lines[identifier.line] ?? []
                
                return ViewModel(
                    line: identifier.line,
                    stations: stations
                )
            }
            
            return LineListViewController(viewModel: vm)
        }
    }
}
