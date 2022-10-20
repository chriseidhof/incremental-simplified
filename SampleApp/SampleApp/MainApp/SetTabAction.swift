import Foundation
import Resin

struct SetTabAction: Action {
    var tab: AppState.Tab
}

struct SetTabReducer: Reducer {
    func reduce(action: SetTabAction, state: inout AppState) {
        state.selectedTab = action.tab
    }
}


