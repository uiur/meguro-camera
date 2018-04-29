import UIKit
import Vision

class BlackLineDrawer {
    class func gravity(points: [CGPoint]) -> CGPoint {
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0

        for point in points {
            x += point.x
            y += point.y
        }

        return CGPoint(
            x: x / CGFloat(points.count),
            y: y / CGFloat(points.count)
        )
    }

    class func draw(leftEyeRegion: [CGPoint], rightEyeRegion: [CGPoint]) -> CALayer {
        let leftEyePoint = gravity(points: leftEyeRegion)
        let rightEyePoint = gravity(points: rightEyeRegion)

        let left = CGPoint(
            x: leftEyePoint.x - 0.4 * (rightEyePoint.x - leftEyePoint.x),
            y: leftEyePoint.y - 0.4 * (rightEyePoint.y - leftEyePoint.y)
        )
        let right = CGPoint(
            x: rightEyePoint.x + 0.4 * (rightEyePoint.x - leftEyePoint.x),
            y: rightEyePoint.y + 0.4 * (rightEyePoint.y - leftEyePoint.y)
        )

        return drawLine(landmarkPoints: [left, right])
    }

    class func drawLine(landmarkPoints: [CGPoint]) -> CALayer {
        let linePath = UIBezierPath()
        linePath.move(to: landmarkPoints.first!)

        for point in landmarkPoints.dropFirst() {
            linePath.addLine(to: point)
        }

        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = nil
        lineLayer.opacity = 1.0
        lineLayer.strokeColor = UIColor.black.cgColor
        lineLayer.lineWidth = 0.2

        return lineLayer
    }
}
