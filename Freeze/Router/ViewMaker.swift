import Combine
import UIKit
import SwiftUI


enum ViewMaker {
    static func makeSplashView(endSplashSubject: PassthroughSubject<Void, Never>) -> UIViewController {
        let splashViewModel = SplashViewModel(endSplashSubject: endSplashSubject)
        let splashViewController = UIHostingController(rootView: SplashView(viewModel: splashViewModel))
        splashViewController.modalPresentationStyle = .fullScreen
        return splashViewController
    }
    
    static func makeCameraView() -> UIViewController {
        let cameraViewModel = CameraViewModel()
        
        let cameraViewController = UIHostingController(rootView: CameraView(viewModel: cameraViewModel))
        cameraViewController.modalPresentationStyle = .fullScreen
        return cameraViewController
    }
}
