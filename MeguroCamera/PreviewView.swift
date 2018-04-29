import UIKit
import Vision
import AVFoundation

class PreviewView: UIView {
    
    private var maskLayer = [CAShapeLayer]()
    
    // MARK: AV capture properties
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    // Create a new layer drawing the bounding box
    private func createLayer(in rect: CGRect) -> CAShapeLayer {
        let mask = CAShapeLayer()
        mask.frame = rect
        mask.cornerRadius = 10
        mask.opacity = 1
        mask.borderColor = UIColor.yellow.cgColor
        mask.borderWidth = 0

        maskLayer.append(mask)
        layer.insertSublayer(mask, at: 1)
        
        return mask
    }
    
    func drawFaceboundingBox(face : VNFaceObservation) {
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frame.height)
        
        let translate = CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height)
        
        // The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
        let facebounds = face.boundingBox.applying(translate).applying(transform)
        
        _ = createLayer(in: facebounds)
    }
    
    func drawFaceWithLandmarks(face: VNFaceObservation) {
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frame.height)
        
        let translate = CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height)

        let facebounds = face.boundingBox.applying(translate).applying(transform)
        
        // Draw the bounding rect
        let faceLayer = createLayer(in: facebounds)
        let blackLineLayer = drawBlackLineLayer(rect: faceLayer.frame, face: face)

        faceLayer.insertSublayer(blackLineLayer, at: 1)
    }

    func drawBlackLineLayer(rect: CGRect, face: VNFaceObservation) -> CALayer {
        let landmarkLayer = BlackLineDrawer.draw(leftEyeRegion: (face.landmarks?.leftEye)!, rightEyeRegion: (face.landmarks?.rightEye)!)

        landmarkLayer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform.identity
                .scaledBy(x: rect.width, y: -rect.height)
                .translatedBy(x: 0, y: -1)
        )

        return landmarkLayer
    }
    
    func removeMask() {
        for mask in maskLayer {
            mask.removeFromSuperlayer()
        }
        maskLayer.removeAll()
    }
    
}
