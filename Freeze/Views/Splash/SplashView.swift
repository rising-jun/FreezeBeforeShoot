import Combine
import SwiftUI


struct SplashView: View {
    @ObservedObject var viewModel: SplashViewModel
    
    var body: some View {
        LogoView()
            .onAppear {
                viewModel.send(.onAppear)
            }
            .onChange(of: viewModel.state.hasPermission) { _, hasPermission
                in
                if hasPermission {
                    viewModel.send(.dismissSplash)
                }
            }
    }
    
    private struct LogoView: View {
        var body: some View {
            VStack(spacing: 8) {
                Spacer()
                Group {
                    LogoTextView(textDirection: .left, textString: "Freeze")
                    LogoTextView(textDirection: .right, textString: "Before")
                    LogoTextView(textDirection: .left, textString: "Shoot")
                }
                .font(.system(size: 30, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 50)
        }
    }
    
    private struct LogoTextView: View {
        let textDirection: Direction
        let textString: String
        var body: some View {
            HStack {
                if textDirection == .right {
                    Spacer()
                    Text(textString)
                } else {
                    Text(textString)
                    Spacer()
                }
            }
        }
    }
    
    enum Direction {
        case right
        case left
    }
}
