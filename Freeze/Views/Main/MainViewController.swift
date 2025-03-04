import Combine
import SwiftUI
import UIKit


final class MainViewController: UIViewController {
    @ObservedObject var viewModel = MainViewModel()
    private var cancelable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.binding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bindingAfterViewDidAppear()
    }
    
    private func binding() {
        
    }
    
    private func bindingAfterViewDidAppear() {
        viewModel.$state
            .map { $0.currentView }
            .sink { [weak self] currentView in
                guard let self else { return }
                switch currentView {
                case .splash:
                    showSplash()
                case .camera:
                    break
                case .main:
                    break
                }
            }
            .store(in: &cancelable)
    }
}
private extension MainViewController {
    func showSplash() {
        let endSplashSubject = PassthroughSubject<Void, Never>()
        let splashViewController = ViewMaker.makeSplashView(endSplashSubject: endSplashSubject)
        endSplashSubject.sink { [weak self] in
            guard let self else { return }
            self.viewModel.send(.endSplash)
            UIView.animate(withDuration: 0.5) {
                splashViewController.view.alpha = 0
            } completion: { _ in
                self.dismiss(animated: true) {
                    self.showCamera()
                }
            }
        }
        .store(in: &cancelable)
        self.present(splashViewController, animated: false)
    }
    
    func showCamera() {
        let cameraViewController = ViewMaker.makeCameraView()
        self.present(cameraViewController, animated: false)
    }
}


final class CommonState {
    private init() { }
    let shared = CommonState()
}
