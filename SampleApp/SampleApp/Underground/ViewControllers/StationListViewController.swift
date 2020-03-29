import Foundation
import Incremental
import Resin
import UIKit

class StationListViewController: UITableViewController {
    let viewModel: I<ViewModel>
    
    private var dataSource: DataSource!
    
    init(viewModel: I<ViewModel>) {
        self.viewModel = viewModel
        super.init(style: .grouped)
        
        title = "All Stations"
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
        
        whileVisible.do { (owner: StationListViewController) in
            [
                owner.bind(keyPath: \.dataSource.stations, to: owner.viewModel[\.stations]),
            ]
        }
    }
}

extension StationListViewController {
    class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
        var stations: [Station] = [] {
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
            cell.textLabel?.text = stations[indexPath.row].name
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let name = stations[indexPath.row].name
            
            let identifier = StationDetailViewController.PresentationIdentifier(name: name)
            tableView.dispatch(ImplicitPresentationAction.push(identifier))
        }
    }
}
    
extension StationListViewController {
    struct ViewModel: Resin.ViewModel, DefaultInit  {
        var stations: [Station] = []
        var isLoading = false
        var isStale = false
    }
}



extension StationListViewController {
    // To Present the VC individually
    struct PresentationIdentifier: Resin.PresentationIdentifier {
        public init() {}
    }
    
    static var presentationRoute: PresentationRoute<PresentationIdentifier, UndergroundState, StationListViewController> {
        return PresentationRoute { _, store in
            
            let vm = store.state.map { undergroundState -> ViewModel in
                ViewModel(
                    stations: undergroundState.stationsState.stations,
                    isLoading: undergroundState.stationStateRequest == .loading
                )
            }
            return StationListViewController(viewModel: vm)
        }
    }
}

extension StationListViewController {
    // to present he VC in a UINavigationController bound to the state
    struct NavigationPresentationIdentifier: Resin.PresentationIdentifier {
    }
    
    static var navigationPresentationRoute: PresentationRoute<NavigationPresentationIdentifier, UndergroundState, UINavigationController> {
        return PresentationRoute { _, store in
            UINavigationController(
                store: store,
                root: StationListViewController.PresentationIdentifier().typeErased,
                navigationStack: \.navigationStack
            )
        }
    }
}
