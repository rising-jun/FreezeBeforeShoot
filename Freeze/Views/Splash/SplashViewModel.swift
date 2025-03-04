import Combine
import SwiftUI


final class SplashViewModel: ObservableObject {
    init(endSplashSubject: PassthroughSubject<Void, Never>) {
        self.endSplashSubject = endSplashSubject
    }
    
    let endSplashSubject: PassthroughSubject<Void, Never>
    @Published var state = State()
    @Dependency(\.permissionClient) private var permissionClient
}
extension SplashViewModel {
    struct State: Equatable {
        var hasPermission: Bool = false
    }
    
    enum Action: Equatable {
        case onAppear
        case dismissSplash
    }
    
    func send(_ action: Action) {
        Task { @MainActor in
            state = await reduce(state, action)
        }
    }
    
    private func reduce(_ state: State, _ action: Action) async -> State {
        var newState = state
        switch action {
        case .onAppear:
            newState.hasPermission = await updateUserPermission()
        case .dismissSplash:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.endSplashSubject.send(())
            }
        }
        return newState
    }
}
private extension SplashViewModel {
    func updateUserPermission() async -> Bool {
        let cameraPermission = await permissionClient.updateCameraPermission()
        let diskPermission = await permissionClient.updateDiskPermission()
        return ((cameraPermission == .authorized) && (diskPermission == .authorized))
    }
    
}
