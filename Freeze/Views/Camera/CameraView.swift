import AVFoundation
import Foundation
import UIKit
import SnapKit
import SwiftUI

struct CameraView: View {
    @State var cameraHandler = CameraHandler()
    @ObservedObject var viewModel: CameraViewModel
    @State var selectedControlCategory: ControlCategory = .filter
    @State var previewImage: UIImage?
    
    var body: some View {
        CameraViewContents(
            cameraHandler: cameraHandler,
            viewModel: viewModel,
            selectedControlCategory: selectedControlCategory
        )
        .onChange(of: viewModel.state.currentImage) { _, newValue in
            previewImage = newValue
        }
        .overlay(alignment: .center) {
            if let previewImage {
                ImagePreview(
                    image: previewImage,
                    cancelButtonTapped: {
                        viewModel.send(.cancelButtonTapped)
                    },
                    saveButtonTapped: {
                        viewModel.send(.saveButtonTapped)
                    }
                )
            }
        }
    }
    
    private struct CameraViewContents: View {
        @State var cameraHandler: CameraHandler
        @ObservedObject var viewModel: CameraViewModel
        @State var selectedControlCategory: ControlCategory
        @State var slidingValue: Float = 7
        @State var filterImage: UIImage?
        
        var body: some View {
            GeometryReader { reader in
                VStack(spacing: 0) {
                    CameraPreview(
                        session: cameraHandler.session,
                        image: $filterImage,
                        filterValue: $viewModel.state.slidingValue,
                        isUsingFrontCamera: $cameraHandler.isUsingFrontCamera
                    )
                    .overlay(alignment: .bottom) {
                        SlidingControlView(slidingValue: $slidingValue)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 16)
                    }
                    .overlay(alignment: .trailing) {
                        FilterSelectSliderView(currentFilterIndex: $viewModel.state.selectedFilterIndex)
                    }
                    .onAppear {
                        cameraHandler.startSession()
                    }
                    .onChange(of: slidingValue) { _, newValue in
                        viewModel.send(.slidingValueChanged(newValue))
                    }
                    CameraBottomControlView(
                        filterTapped: { viewModel.send(.filterTapped) },
                        correctTapped: { viewModel.send(.correctTapped) },
                        takePhotoButtonTapped: { viewModel.send(.captured(filterImage)) },
                        selectedControlCategory: $selectedControlCategory,
                        cameraHandler: cameraHandler,
                        reader: reader
                    )
                }
                .onReceive(cameraHandler.$captureImage) { image in
                    viewModel.send(.captured(image))
                }
            }
        }
    }
    
    private struct FilterSelectSliderView: View {
        @Binding var currentFilterIndex: Int
        let selectedColor: Color = .white
        let deselectedColor: Color = .white.opacity(0.7)
        let items: [String] = ["세피아", "흑백", "크롬", "빈티지", "페이드", "색상반전"]
        @State var isHidden: Bool = false
        
        var body: some View {
            VStack {
                Text("현재 필터: \(items[currentFilterIndex])")
                    .font(.headline)
                    .opacity(isHidden ? 0.0 : 1.0)
                    .padding()
                
                TabView(selection: $currentFilterIndex) {
                    ForEach(items.indices, id: \.self) { index in
                        Group {
                            Text(items[index])
                                .font(.largeTitle)
                                .foregroundStyle(Color.black)
                                .frame(width: 200, height: 200)
                                .background(Color.black.opacity(0.2))
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color.black, lineWidth: 3)
                                )
                                .tag(index)
                        }
                        .opacity(isHidden ? 0.0 : 1.0)
                    }
                }
                .frame(height: 220)
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .onChange(of: currentFilterIndex) { _, _ in
                isHidden = false
            }
            .onChange(of: isHidden) { _, newValue in
                if !newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isHidden = true
                    }
                }
            }
            .onAppear {
                if !isHidden {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isHidden = true
                    }
                }
            }
        }
    }
    
    private struct CameraBottomControlView: View {
        let filterTapped: (() -> Void)
        let correctTapped: (() -> Void)
        let takePhotoButtonTapped: (() -> Void)
        @Binding var selectedControlCategory: ControlCategory
        let cameraHandler: CameraHandler
        let reader: GeometryProxy
        
        var body: some View {
            Rectangle()
                .frame(width: UIScreen.main.bounds.width, height: CameraBottomControlHeight)
                .overlay(alignment: .top) {
                    HStack(spacing: reader.size.width * 0.07) {
                        Spacer()
                        Text("filter")
                            .foregroundStyle(selectedControlCategory == .filter ? Color.black : Color.black.opacity(0.4))
                            .onTapGesture {
                                filterTapped()
                                selectedControlCategory = .filter
                            }
                        Text("correct")
                            .foregroundStyle(selectedControlCategory == .correct ? Color.black : Color.black.opacity(0.4))
                            .onTapGesture {
                                correctTapped()
                                selectedControlCategory = .correct
                            }
                        Spacer()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.top, 12)
                }
                .overlay {
                    VStack(spacing: 0) {
                        Spacer()
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay {
                                Circle()
                                    .stroke(Color.black, lineWidth: 3)
                                    .padding(5)
                            }
                            .onTapGesture {
                                takePhotoButtonTapped()
                            }
                            .padding(.bottom, 27)
                    }
                }
                .overlay(alignment: .trailing) {
                    VStack(spacing: 0) {
                        Spacer()
                        Circle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 22))
                                    .foregroundStyle(Color.white)
                                    .padding(8)
                            }
                            .onTapGesture {
                                cameraHandler.toggleCamera()
                            }
                            .padding(.trailing, 16)
                            .padding(.bottom, 32)
                    }
                }
        }
    }
    
    private struct SlidingControlView: View {
        @Binding var slidingValue: Float
        var body: some View {
            VStack(spacing: 0) {
                Text("\(Int(slidingValue))")
                    .font(.system(size: 12))
                Slider(value: $slidingValue, in: 1...10)
                    .tint(Color.white)
            }
            .foregroundStyle(Color.white)
        }
    }
    
    private struct ImagePreview: View {
        let image: UIImage
        let cancelButtonTapped: (() -> Void)
        let saveButtonTapped: (() -> Void)
        var body: some View {
            GeometryReader { reader in
                ZStack {
                    Color.black
                    VStack(spacing: 0) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .clipped()
                            .frame(width: reader.size.width - 25, height: reader.size.height - 150)
                            .padding(.top, 24)
                        HStack(spacing: 18) {
                            Spacer()
                            CapsuleImageTextButton(
                                systemImage: "xmark",
                                text: "cancel",
                                width: reader.size.width * 0.4
                            ) {
                                cancelButtonTapped()
                            }
                            CapsuleImageTextButton(
                                systemImage: "arrow.down.circle",
                                text: "save",
                                width: reader.size.width * 0.4
                            ) {
                                saveButtonTapped()
                            }
                            Spacer()
                        }
                        .padding(32)
                    }
                }
                .frame(width: reader.size.width, height: reader.size.height)
            }
        }
    }
    
    private struct CapsuleImageTextButton: View {
        let systemImage: String
        let text: String
        let width: CGFloat
        let tapEvent: (() -> Void)
        var body: some View {
            Button {
                tapEvent()
            } label: {
                HStack(spacing: 10) {
                    Spacer()
                    Image(systemName: systemImage)
                        .font(.system(size: 16))
                    Text(text)
                        .font(.system(size: 16))
                    Spacer()
                }
                .frame(width: width)
                .foregroundStyle(Color.white)
                .padding(.vertical, 10)
                .clipShape(Capsule())
                .overlay {
                    Capsule().stroke(Color.white, lineWidth: 1)
                }
            }
        }
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    let session: AVCaptureSession
    let filter: CIFilter = CIFilter(name: "CISepiaTone")!
    let imageView = UIImageView()
    @State var previewLayer: AVCaptureVideoPreviewLayer?
    @Binding var image: UIImage?
    @Binding var filterValue: Float
    @Binding var isUsingFrontCamera: Bool
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraPreview
        var context: CIContext = .init()
        
        init(parent: CameraPreview) {
            self.parent = parent
            self.context = CIContext()
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            DispatchQueue.main.async {
                guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                    return
                }
                
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                
                self.parent.filter.setValue(ciImage, forKey: kCIInputImageKey)
                self.parent.filter.setValue(self.parent.filterValue / 10, forKey: kCIInputIntensityKey)
                
                if let outputImage = self.parent.filter.outputImage {
                    if let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent) {
                        let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: self.parent.isUsingFrontCamera ? .leftMirrored : .right)
                        self.parent.imageView.image = uiImage
                        self.parent.image = uiImage
                    }
                }
            }
        }
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Preview layer 설정
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        let viewFrame: CGRect = .init(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height - 200
        )
        previewLayer.frame = viewFrame
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        // 비디오 출력 설정
        let videoDataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            
            let videoQueue = DispatchQueue(label: "videoQueue")
            videoDataOutput.setSampleBufferDelegate(context.coordinator, queue: videoQueue)
        }
        
        // previewLayer 바인딩
        DispatchQueue.main.async {
            self.previewLayer = previewLayer
        }
        
        viewController.view.addSubview(self.imageView)
        imageView.frame = viewFrame
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}
let CameraBottomControlHeight = 180.0


final class CameraHandler: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    private var videoInput: AVCaptureDeviceInput?
    var isUsingFrontCamera = false
    @Published var captureImage: UIImage?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func setupCamera() {
        session.beginConfiguration()
        if let currentInput = videoInput {
            session.removeInput(currentInput)
        }
        
        let cameraPosition: AVCaptureDevice.Position = isUsingFrontCamera ? .front : .back
        guard let videoCaptureDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: cameraPosition
        ) else {
            return
        }
        
        videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        guard let videoInput else { return }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        
        if let photoOutput = photoOutput, session.outputs.contains(photoOutput) {
            session.removeOutput(photoOutput)
        }
        
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput, session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        session.commitConfiguration()
    }
    
    func startSession() {
        Task {
            session.startRunning()
        }
    }
    
    func toggleCamera() {
        isUsingFrontCamera.toggle()
        setupCamera()
    }
}
