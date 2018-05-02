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

        let leftEdgePoint = leftEyeRegion.min(by: { (a, b) in a.x < b.x })!
        let rightEdgePoint = rightEyeRegion.max(by: { (a, b) in a.x < b.x })!

        let edgeDistance = distance(a: leftEdgePoint, b: rightEdgePoint)
        let centerDistance = distance(a: leftEyePoint, b: rightEyePoint)
        let ratio = (edgeDistance - centerDistance) / centerDistance


        let left = CGPoint(
            x: leftEyePoint.x - ratio * (rightEyePoint.x - leftEyePoint.x),
            y: leftEyePoint.y - ratio * (rightEyePoint.y - leftEyePoint.y)
        )
        let right = CGPoint(
            x: rightEyePoint.x + ratio * (rightEyePoint.x - leftEyePoint.x),
            y: rightEyePoint.y + ratio * (rightEyePoint.y - leftEyePoint.y)
        )

        return drawLine(landmarkPoints: [left, right])
    }


    class func distance(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
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
