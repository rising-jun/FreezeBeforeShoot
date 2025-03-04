import Foundation
import UIKit


final class CameraViewModel: ObservableObject {
    @Published var state = State()
    
    struct State: Equatable {
        var currentImage: UIImage?
        var selectedControlCategory: ControlCategory = .filter
        var slidingValue: Float = 7.0
        var selectedFilterIndex: Int = 0
    }
    
    enum Action: Equatable {
        case captured(UIImage?)
        case filterTapped
        case correctTapped
        case slidingValueChanged(Float)
        
        //preview
        case cancelButtonTapped
        case saveButtonTapped
    }
    
    func send(_ action: Action) {
        state = reduce(state, action)
    }
    
    private func reduce(_ state: State, _ action: Action) -> State {
        var newState = state
        switch action {
        case .captured(let image):
            if let image {
                newState.currentImage = image.cropBottom(height: CameraBottomControlHeight)
            }
        case .filterTapped:
            newState.selectedControlCategory = .filter
        case .correctTapped:
            newState.selectedControlCategory = .correct
        case .slidingValueChanged(let value):
            newState.slidingValue = value
        case .cancelButtonTapped:
            newState.currentImage = nil
        case .saveButtonTapped:
            break
        }
        return newState
    }
}
enum ControlCategory: Equatable {
    case correct
    case filter
}
