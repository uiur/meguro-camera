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
        let leftEyePoint = gravity(faceLandmarkRegion: (face.landmarks?.leftEye)!)
        let rightEyePoint = gravity(faceLandmarkRegion: (face.landmarks?.rightEye)!)

        let left = CGPoint(
            x: leftEyePoint.x - 0.4 * (rightEyePoint.x - leftEyePoint.x),
            y: leftEyePoint.y - 0.4 * (rightEyePoint.y - leftEyePoint.y)
        )
        let right = CGPoint(
            x: rightEyePoint.x + 0.4 * (rightEyePoint.x - leftEyePoint.x),
            y: rightEyePoint.y + 0.4 * (rightEyePoint.y - leftEyePoint.y)
        )

        let landmarkLayer = drawPointsOnLayer(landmarkPoints: [left, right])

        landmarkLayer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform.identity
                .scaledBy(x: rect.width, y: -rect.height)
                .translatedBy(x: 0, y: -1)
        )

        return landmarkLayer
    }

    func gravity(faceLandmarkRegion: VNFaceLandmarkRegion2D) -> CGPoint {
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0

        for i in 0..<faceLandmarkRegion.pointCount {
            let point = faceLandmarkRegion.normalizedPoints[i]
            x += point.x
            y += point.y
        }

        return CGPoint(
            x: x / CGFloat(faceLandmarkRegion.pointCount),
            y: y / CGFloat(faceLandmarkRegion.pointCount)
        )
    }
    
    func drawPointsOnLayer(landmarkPoints: [CGPoint], isClosed: Bool = true) -> CALayer {
        let linePath = UIBezierPath()
        linePath.move(to: landmarkPoints.first!)
        
        for point in landmarkPoints.dropFirst() {
            linePath.addLine(to: point)
        }
        
        if isClosed {
            linePath.addLine(to: landmarkPoints.first!)
        }
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = nil
        lineLayer.opacity = 1.0
        lineLayer.strokeColor = UIColor.black.cgColor
        lineLayer.lineWidth = 0.2
        
        return lineLayer
    }
    
    func removeMask() {
        for mask in maskLayer {
            mask.removeFromSuperlayer()
        }
        maskLayer.removeAll()
    }
    
}
