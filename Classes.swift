//
//  Classes.swift
//  Mosaico Church - Predicaciones
//
//  Created by Xander Morrison on 1/31/21.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class TrackLayer: UIControl {
    
    let circleLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    var value: CGFloat = 0
    
    let radius: CGFloat = 100
    
    var knob: KnobControl?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        let center = CGPoint(x: frame.midX, y: frame.midY + 70) // added 50
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 1.5, clockwise: true)
        
        setUpTrackLayer(path)
        setUpCircleLayer(path)
        layer.addSublayer(trackLayer)
        layer.addSublayer(circleLayer)
        
        knob = KnobControl(frame: self.bounds)
        addSubview(knob!)
        knob!.addTarget(self, action: #selector(TrackLayer.updateTrack(_:)), for: .valueChanged)
        knob!.addTarget(self, action: #selector(TrackLayer.updateTrack(_:)), for: .touchDown)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpTrackLayer(_ path: UIBezierPath) {
        trackLayer.path = path.cgPath
        trackLayer.frame = self.bounds
        trackLayer.strokeColor = UIColor.systemGray2.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 20
        trackLayer.lineCap = .round
        trackLayer.strokeEnd = 1
    }
    
    func setUpCircleLayer(_ path: UIBezierPath) {
        circleLayer.path = path.cgPath
        circleLayer.frame = self.bounds
        circleLayer.strokeColor = UIColor.systemBlue.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 20
        circleLayer.lineCap = .round
        circleLayer.strokeEnd = 0
    }
    
    @objc func updateTrack(_ control: KnobControl) {
        self.value = control.value
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        circleLayer.strokeEnd = self.value
        CATransaction.commit()
        self.sendActions(for: .valueChanged)
    }
}

class KnobControl: UIControl, UIGestureRecognizerDelegate {
    let knobLayer = CAShapeLayer()
    
    var angle: CGFloat = 0
    var distance: CGFloat = 100
    var radius: CGFloat = 15
    var diameter: CGFloat {
        get {
            radius * 2
        }
        set {
            self.radius = CGFloat(newValue) / CGFloat(2)
        }
    }
    
    var value: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let knobCenter = CGPoint(x: self.frame.midX, y: self.frame.midY - distance)
        let knobPath = UIBezierPath(arcCenter: knobCenter, radius: radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        setUpKnobLayer(knobPath)
        layer.addSublayer(knobLayer)

        let gestureRecog = RotationGestureRecognizer(target: self, action: #selector(KnobControl.handleGesture(_:)))
        gestureRecog.delegate = self
        addGestureRecognizer(gestureRecog)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpKnobLayer(_ path: UIBezierPath) {
        knobLayer.path = path.cgPath
        knobLayer.frame = self.bounds
        knobLayer.position = CGPoint(x: knobLayer.position.x, y: knobLayer.position.y + 70) // added 50
        knobLayer.fillColor = UIColor.systemBlue.cgColor
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        let opposite = sin(angle - CGFloat.pi / 2) * distance
        let adjacent = cos(angle - CGFloat.pi / 2) * distance
        let knobCenter = CGPoint(x: knobLayer.position.x + adjacent, y: knobLayer.position.y + opposite)
        let origin = CGPoint(x: knobCenter.x - radius * 2, y: knobCenter.y - radius * 2)
        let frameOfKnob = CGRect(x: origin.x, y: origin.y, width: diameter + radius, height: diameter + radius)
        let status = frameOfKnob.contains(location)
        return status
    }
    
    func moveTimeline(_ newValue: CGFloat) {
        angle = newValue
        if angle < 0 {
            value = (2 * CGFloat.pi + angle) / (2 * CGFloat.pi)
        } else {
            value = angle / (2 * CGFloat.pi)
        }
        self.sendActions(for: .valueChanged)
        rotateKnob(newValue)
    }
    
    func rotateKnob(_ newValue: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        knobLayer.transform = CATransform3DMakeRotation(newValue, 0, 0, 1)
        CATransaction.commit()
    }
    
    @objc func handleGesture(_ gesture: RotationGestureRecognizer) {
        moveTimeline(gesture.touchAngle)
        self.sendActions(for: .touchDown)
    }
}

class RotationGestureRecognizer: UIPanGestureRecognizer {
    var touchAngle: CGFloat = 0
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        
        maximumNumberOfTouches = 1
        minimumNumberOfTouches = 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        updateAngle(with: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        updateAngle(with: touches)
    }
    
    private func updateAngle(with touches: Set<UITouch>) {
        guard
            let touch = touches.first,
            let view = self.view
        else {
            return
        }
        let touchPoint = touch.location(in: view)
        touchAngle = angle(for: touchPoint, in: view)
    }
    
    private func angle(for point: CGPoint, in view: UIView) -> CGFloat {
        let centerOffset = CGPoint(x: point.x - view.bounds.midX, y: point.y - view.bounds.midY - 70) // subtracted 50
        return atan2(centerOffset.y, centerOffset.x) + (CGFloat.pi / 2)
    }
}
