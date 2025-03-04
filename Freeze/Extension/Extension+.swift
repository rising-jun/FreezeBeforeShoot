import UIKit


extension UIImage {
    func cropBottom(height: CGFloat) -> UIImage? {
        let newHeight = size.height - (size.height * 0.18)
        guard newHeight > 0 else { return nil }
        let rect = CGRect(x: 0, y: 100, width: size.width, height: newHeight + 100)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
        self.draw(at: .zero)
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
}
