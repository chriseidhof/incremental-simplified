import Foundation
import Resin

public struct AppState: Equatable {
    enum Tab: Int, Equatable {
        case underground = 0
        case ticket = 1
    }
    
    var counter: Int = 0

    var undergroundState: UndergroundState = UndergroundState()

    var modalStack: [AnyPresentationIdentifier] = []
    
    var selectedTab: Tab = .underground
}


