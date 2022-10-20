import Foundation
import Incremental
import Resin
import SafariServices
import UIKit

class StationDetailViewController: UITableViewController {
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
        
        whileVisible.do { (owner: StationDetailViewController) in
            [
                owner.bind(keyPath: \.title, to: owner.viewModel[\.station.name]),
                owner.bind(keyPath: \.dataSource.viewModel, to: owner.viewModel),
            ]
        }
     }
}

extension StationDetailViewController {
    class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
        var viewModel = StationDetailViewController.ViewModel() {
            didSet {
                tableView?.reloadData()
            }
        }
        
        weak var tableView: UITableView?
        
        init(tableView: UITableView) {
            self.tableView = tableView
            super.init()
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 4
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch section {
            case 0:
                return 2
            case 1:
                return viewModel.station.lines.count
            case 2:
                return 1
            case 3:
                return 1
            default:
                fatalError()
            }
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: UITableViewCell
            
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Name"
                cell.detailTextLabel?.text = viewModel.station.name
                
            case (0, 1):
                cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Zones"
                cell.detailTextLabel?.text = viewModel.station.zones.map(String.init).joined(separator: " & ")
                
            case (1, let line):
                cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = viewModel.station.lines[line]
                
            case (2, 0):
                let `switch` = UISwitch()
                `switch`.setOn(viewModel.isFavorite, animated: false)
                `switch`.on(.valueChanged, dispatch: ToggleFavoriteAction(station: viewModel.station.name))
                
                cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.accessoryView = `switch`
                cell.textLabel?.text = "Favorite"
                
            case (3, 0):
                cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "Wikipedia Article"
            default:
                fatalError()
            }
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            switch section {
            case 0, 2, 3:
                return nil
            case 1:
                return "Lines"
            default:
                fatalError()
            }
        }
        
        func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
            return indexPath.section == 1 || indexPath.section == 3
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            switch (indexPath.section, indexPath.row) {
            case (1, let line):
                let identifier = LineListViewController.PresentationIdentifier(line: viewModel.station.lines[line])
                
                tableView.dispatch(ImplicitPresentationAction.push(identifier))
            case (3, 0):
                let identifier = SFSafariViewController.PresentationIdentifier(url: URL(string: "http://example.org")!)
                
                tableView.dispatch(ImplicitPresentationAction.push(identifier))
            default:
                fatalError()
            }
        }
    }
}

extension StationDetailViewController {
    struct ViewModel: Resin.ViewModel, DefaultInit  {
        var station: Station = Station(name: "", lines: [], zones: [])
        var isFavorite = false
        var isStale = false
    }
}

extension StationDetailViewController {
    struct PresentationIdentifier: Resin.PresentationIdentifier {
        public var name: String

        public init(name: String) {
            self.name = name
        }
    }
    
    static var presentationRoute: PresentationRoute<PresentationIdentifier, UndergroundState, StationDetailViewController> {
        return PresentationRoute { identifier, store in
            let viewModel = store.state
                .mapWithFallback {
                    StationDetailViewController.ViewModel(stationName: identifier.name, state: $0)
                }
            
            return StationDetailViewController(viewModel: viewModel)
        }
    }
}

extension StationDetailViewController.ViewModel {
    init?(stationName: String, state: UndergroundState) {
        guard let station = state.stationsState.find(byName: stationName) else {
            return nil
        }
        
        self.init(
            station: station,
            isFavorite: state.favoriteStations.contains(stationName)
        )
    }
}
