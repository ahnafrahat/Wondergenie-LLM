//
//  Utility.swift
//  WanderGenie_Test
//
//  Created by Ahnaf Rahat on 22/5/25.
//
import UIKit
import Foundation

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    func removeAllSubviews(){
        for __view in self.subviews{
            __view.removeFromSuperview()
        }
    }
    
    func addBorder(edges: UIRectEdge, color: UIColor = UIColor.white, thickness: CGFloat = 1) -> [UIView]{
        
        var borders = [UIView]()
        
        func border() -> UIView {
            let border = UIView(frame: CGRect.zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            let top = border()
            addSubview(top)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[top]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            let left = border()
            addSubview(left)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[left(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["left": left]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[left]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            let right = border()
            addSubview(right)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["right": right]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["bottom": bottom]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[bottom]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
    
    func removeBorder(borders: [UIView]){
        for _view in borders{
            _view.removeFromSuperview()
        }
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addDropShadow(_ color: UIColor? = nil, shadowRadius: CGFloat? = nil, shadowOffset: CGSize? = nil, shadowOpacity: Float? = nil) {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = color != nil ? color!.cgColor : UIColor.black.cgColor
        self.layer.shadowOpacity = shadowOpacity != nil ? shadowOpacity! : 0.5
        self.layer.shadowOffset = shadowOffset != nil ? shadowOffset! : CGSize(width: 0, height: 1)
        self.layer.shadowRadius = shadowRadius != nil ? shadowRadius! : 1.0
        
        //self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shouldRasterize = false
    }
    
    func startSpinning() {
        let spinAnimation = CABasicAnimation()
        spinAnimation.fromValue = 0
        spinAnimation.toValue = Double.pi * 2
        spinAnimation.duration = 2.5
        spinAnimation.repeatCount = Float.infinity
        spinAnimation.isRemovedOnCompletion = false
        layer.add(spinAnimation, forKey: "transform.rotation.z")
    }
    
    func stopSpinning() {
        layer.removeAllAnimations()
    }
    
    func lock() {
        if let _ = viewWithTag(10) {
            //View is already locked
        }
        else {
            let lockView = UIView(frame: bounds)
            lockView.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
            lockView.tag = 10
            lockView.alpha = 0.0
            let activity = UIActivityIndicatorView(style: .white)
            activity.hidesWhenStopped = true
            activity.center = lockView.center
            lockView.addSubview(activity)
            activity.startAnimating()
            addSubview(lockView)
            
            UIView.animate(withDuration: 0.2, animations: {
                lockView.alpha = 1.0
            })
        }
    }
    
    func unlock() {
        if let lockView = viewWithTag(10) {
            UIView.animate(withDuration: 0.2, animations: {
                lockView.alpha = 0.0
            }, completion: { finished in
                lockView.removeFromSuperview()
            })
        }
    }
    
    func fadeOut(_ duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
    
    func fadeIn(_ duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    class func viewFromNibName(_ name: String) -> UIView? {
        let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        return views?.first as? UIView
    }
}
