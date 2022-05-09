// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import SnapKit

//MARK: - Actions

public class ActionWrapper {
    let action: () -> ()
    
    public init(_ action: @escaping () -> ()) {
        self.action = action
    }
    
    @objc func trigger() {
        action()
    }
}

public extension UIControl {
    func setAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping () -> ()) {
        let wrapper = ActionWrapper(closure)
        addTarget(wrapper, action: #selector(ActionWrapper.trigger), for: controlEvents)
        objc_setAssociatedObject(self, String(ObjectIdentifier(self).hashValue) + String(controlEvents.rawValue), wrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}


extension UIImage {
    func blendedByColor(_ color: UIColor) -> UIImage {
        let scale = UIScreen.main.scale
        if scale > 1 {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
        } else {
            UIGraphicsBeginImageContext(size)
        }
        color.setFill()
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(bounds)
        draw(in: bounds, blendMode: .destinationIn, alpha: 1)
        let blendedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blendedImage!
    }
    
    func enlarge(to size: CGSize) -> UIImage {
        let result = UIView()
        result.frame = CGRect(origin: .zero, size: size)
        let iv = UIImageView(image: self)
        result.addSubview(iv)
        if self.size.width < size.width {
            let w = self.size.width
            let h = self.size.height
            iv.frame = CGRect(x: (size.width - w) / 2.0, y: (size.height - h) / 2.0, width: w, height: h)
        } else {
            iv.contentMode = .scaleAspectFit
            iv.frame = result.frame
        }
        return result.asImage()
    }
}

final class BlockTap: UITapGestureRecognizer, UIGestureRecognizerDelegate {
    private var tapAction: ((UITapGestureRecognizer) -> Void)?
    private var shouldReceive: ((UITouch) -> Bool)?
    
    override public init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    convenience init(tapCount: Int = 1, fingerCount: Int = 1,
                     action: ((UITapGestureRecognizer) -> Void)?,
                     shouldReceiveTouch: ((UITouch) -> Bool)? = nil)
    {
        self.init()
        
        numberOfTapsRequired = tapCount
        numberOfTouchesRequired = fingerCount
        
        tapAction = action
        shouldReceive = shouldReceiveTouch
        addTarget(self, action: #selector(BlockTap.didTap(_:)))
        
        delegate = self
    }
    
    @objc func didTap(_ tap: UITapGestureRecognizer) {
        if tap.state == .ended {
            tapAction?(tap)
        }
    }
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        shouldReceive?(touch) ?? true
    }
}


extension UIViewController {
    
    func addHideKeyboardWhenTappedAroundBehaviour() {
        let tap = BlockTap { [weak self] r in
            if r.state == .ended {
                self?.view.endEditing(true)
            }
        }
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

private var keyboardChangeFrameObserverTokenHandle: UInt8 = 0

//MARK: - Observers
extension UIViewController {
    
    var keyboardChangeFrameObserverToken: NSObjectProtocol? {
        get {
            return objc_getAssociatedObject(self, &keyboardChangeFrameObserverTokenHandle) as? NSObjectProtocol
        }
        set {
            objc_setAssociatedObject(self, &keyboardChangeFrameObserverTokenHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addObserverForNotification(_ notificationName: Notification.Name, object: Any? = nil, actionBlock: @escaping (Notification) -> Void) {
        NotificationCenter.default.addObserver(forName: notificationName, object: object, queue: OperationQueue.main, using: actionBlock)
    }
    
    func removeObserver(_ observer: AnyObject, notificationName: Notification.Name, object: Any? = nil) {
        NotificationCenter.default.removeObserver(observer, name: notificationName, object: object)
    }
}

//MARK: - Keyboard handling
extension UIViewController {
    
    typealias KeyboardHeightClosure = (CGFloat) -> ()
    
    func addKeyboardChangeFrameObserver(willShow willShowClosure: KeyboardHeightClosure?,
                                        willHide willHideClosure: KeyboardHeightClosure?) {
        keyboardChangeFrameObserverToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification,
                                                                                  object: nil, queue: OperationQueue.main, using: { [weak self](notification) in
            if let userInfo = notification.userInfo,
               let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
               let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
               let c = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
               let kFrame = self?.view.convert(frame, from: nil),
               let kBounds = self?.view.bounds {
                
                let animationType = UIView.AnimationOptions(rawValue: c)
                let kHeight = kFrame.size.height
                UIView.animate(withDuration: duration, delay: 0, options: animationType, animations: {
                    if kBounds.intersects(kFrame) { // keyboard will be shown
                        willShowClosure?(kHeight)
                    } else { // keyboard will be hidden
                        willHideClosure?(kHeight)
                    }
                }, completion: nil)
            } else {
                print("Invalid conditions for UIKeyboardWillChangeFrameNotification")
            }
        })
    }
    
    func removeKeyboardObserver() {
        removeObserver(self, notificationName: UIResponder.keyboardWillChangeFrameNotification)
    }
}


final class ProtectedTextView: UITextView, UITextViewDelegate {
    
    var isProtected = true {
        didSet {
            if isProtected {
                text = protectedText(plainText)
                font = UIFont.systemFont(ofSize: 18, weight: .bold)
            } else {
                text = plainText
                font = UIFont.systemFont(ofSize: 16, weight: .regular)
            }
        }
    }
    var plainText: String = "" {
        didSet {
            onChangeText(plainText)
        }
    }
    private let onChangeText: (String) -> ()
    
    init(textColor: UIColor, onChangeText: @escaping (String) -> ()) {
        self.onChangeText = onChangeText
        super.init(frame: .zero, textContainer: nil)
        
        self.textColor = textColor
        delegate = self
        backgroundColor = .clear
        autocorrectionType = .no
        spellCheckingType = .no
        autocapitalizationType = .none
        smartDashesType = .no
        font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text as NSString).rangeOfCharacter(from: .newlines).location == NSNotFound {
            plainText = (plainText as NSString).replacingCharacters(in: range, with: text)
            return true
        }
        textView.resignFirstResponder()
        return false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if isProtected {
            textView.text = protectedText(textView.text)
        }
    }
    
    private func protectedText(_ text: String) -> String {
        let parts = text.components(separatedBy: .whitespaces).map { part in
            String(repeating: "•", count: part.count)
        }
        let result = parts.joined(separator: " ")
        return result
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: frame.size)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}

public extension UIApplication {
    static func getKeyWindow() -> UIWindow? {
        if #available(iOS 13, *) {
            return shared.windows.first(where: { $0.isKeyWindow })
        } else {
            return shared.keyWindow
        }
    }
}

public extension UIView {
    var loader: LoaderView? {
        subviews.first(where: { $0 is LoaderView }) as? LoaderView
    }

    func showLoader(title: String = "") {
        let loader = LoaderView(frame: bounds, text: title)
        if subviews.filter({ $0 is LoaderView }).isEmpty {
            addSubview(loader)
        }
    }

    func removeLoader() {
        if let loader = subviews.first(where: { $0 is LoaderView }) {
            loader.removeFromSuperview()
        }
    }
}

public class LoaderView: UIView {
    public var blurEffectView: UIVisualEffectView?

    public init(frame: CGRect, text: String = "") {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView = blurEffectView
        super.init(frame: frame)
        addSubview(blurEffectView)
        addLoader(text: text)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLoader(text: String) {
        guard let blurEffectView = blurEffectView else { return }
        var activityIndicator: UIActivityIndicatorView

        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .large)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        let label = UILabel()

        label.text = text
        label.textAlignment = .center
        blurEffectView.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(50)
            make.height.equalTo(30)
        }

        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalToSuperview()
        }

        activityIndicator.center = blurEffectView.contentView.center
        activityIndicator.startAnimating()
    }
}
