import Combine


final class MainViewModel: ObservableObject {
    @Published var state = State()
    
    struct State: Equatable {
        var currentView: Views = .splash
    }
    
    enum Action: Equatable {
        case endSplash
    }
    
    enum Views {
        case splash
        case camera
        case main
    }
    
    func send(_ action: Action) {
        state = reduce(state, action)
    }
    
    private func reduce(_ state: State, _ action: Action) -> State {
        var newState = state
        switch action {
        case .endSplash:
            newState.currentView = .camera
        }
        return newState
    }
}
