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
    
    var limit: Int = 0
    
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
            if limit > 0, plainText.count >= limit {
                return false
            }
            SwiftTryCatch.try({
                plainText = (plainText as NSString).replacingCharacters(in: range, with: text)
            }, catch: { error in
                
            }, finally: {
                
            })
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
    fileprivate var loader: LoaderView? {
        subviews.first(where: { $0 is LoaderView }) as? LoaderView
    }

    func showLoader(title: String = "") {
        DispatchQueue.main.async {
            let loader = LoaderView(frame: self.bounds, text: title)
            if self.subviews.filter({ $0 is LoaderView }).isEmpty {
                self.addSubview(loader)
            }
        }
    }

    func removeLoader() {
        DispatchQueue.main.async {
            if let loader = self.subviews.first(where: { $0 is LoaderView }) {
                loader.removeFromSuperview()
            }
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

public enum ScreenScale: CGFloat, Equatable {
    case x1 = 1.0
    case x2 = 2.0
    case x3 = 3.0
    case unknown = 0
}

//https://www.ios-resolution.com/
public enum ScreenSize: Comparable {
    /// iPhone 5, SE
    case undefined_small
    /// iPhone 6, 6s, 7, 8
    case inches_4_7
    /// iPhone 6+, 6s+, 7+, 8+
    case inches_5_5
    /// iPhone  X, Xs, 11 Pro, 12/13 Mini
    case inches_5_8
    /// iPhone Xr, 11, 12, 12, 13 Pro
    case inches_6_1
    /// iPhone Xs Max, 11 Pro Max
    case inches_6_5
    /// iPhone 12/13 Pro Max
    case inches_6_7
    /// iPhone with height > 926 points
    case undefined_big
}

public extension UIScreen {
    static var wpScale: ScreenScale {
        switch UIScreen.main.scale {
        case 1.0: return .x1
        case 2.0: return .x2
        case 3.0: return .x3
        default: return .unknown
        }
    }
    
    static var isSmall: Bool {
        UIScreen.screenSize < .inches_4_7
    }

    static var screenSize: ScreenSize {
        let size = UIScreen.main.bounds.size
        let height = max(size.width, size.height)

        switch height {
        case 0 ..< 667: return .undefined_small
        case 667: return (wpScale == .x3 ? .inches_5_5 : .inches_4_7)
        case 736: return .inches_5_5
        case 812: return .inches_5_8
        case 844: return .inches_6_1
        case 896: return (wpScale == .x3 ? .inches_6_5 : .inches_6_1)
        case 926: return .inches_6_7
        case let x where x > 926: return .undefined_big
        default: return .undefined_big
        }
    }
}

public extension UIDevice {
    static var isSmall: Bool {
        UIScreen.screenSize <= .inches_4_7
    }
}

extension UserDefaults {
    enum Keys {}
    
    func typedValue<T>(forKey key: String) -> T? {
        let result = value(forKey: key)
        return result as? T
    }
}

@propertyWrapper
public struct UserDefault<T: Equatable> {
    let key: String
    let defaultValue: T
    
    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public init<ValueType>(key: String) where T == Optional<ValueType> {
        self.key = key
        self.defaultValue = nil
    }

    public var wrappedValue: T {
        get {
            if let val: T = UserDefaults.standard.typedValue(forKey: key) {
                return val
            } else {
                UserDefaults.standard.set(defaultValue, forKey: key)
                return defaultValue
            }
        }
        set {
            if let metatype = T.self as? ExpressibleByNilLiteral.Type {
                let metaNil = metatype.init(nilLiteral: ()) as? T
                if metaNil == newValue {
                    UserDefaults.standard.removeObject(forKey: key)
                } else {
                    UserDefaults.standard.set(newValue, forKey: key)
                }
                
            } else {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
}

@propertyWrapper
public struct UserDefaultData<T: Codable> {
    let key: String
    let defaultValue: T
    
    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public init<ValueType>(key: String) where T == Optional<ValueType> {
        self.key = key
        self.defaultValue = nil
    }
    
    public var wrappedValue: T {
        get {
            if let data = UserDefaults.standard.object(forKey: key) as? Data,
               let user = try? JSONDecoder().decode(T.self, from: data) {
                return user
                
            }
            
            return  defaultValue
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: key)
            }
        }
    }
}

@propertyWrapper
public struct FileCacheData<T: Codable> {
    let fileUrl: URL
    let defaultValue: T

    public init<ValueType>(directory: FileManager.SearchPathDirectory, fileName: String) where T == ValueType? {
        fileUrl = FileManager.default.urls(for: directory, in: .userDomainMask).first!.appendingPathComponent(fileName, isDirectory: false)
        defaultValue = nil
    }

    public init(fileUrl: URL, defaultValue: T) {
        self.fileUrl = fileUrl
        self.defaultValue = defaultValue
    }

    public init<ValueType>(fileUrl: URL) where T == ValueType? {
        self.fileUrl = fileUrl
        defaultValue = nil
    }

    public var wrappedValue: T {
        get {
            if let data = try? Data(contentsOf: fileUrl),
               let value = try? JSONDecoder().decode(T.self, from: data)
            {
                return value
            }

            return defaultValue
        }
        set {
            if let encodedData = try? JSONEncoder().encode(newValue) {
                try? encodedData.write(to: fileUrl, options: .atomic)
            }
        }
    }
}

var uiBarButtonItemKey: UInt8 = 0

extension UIBarButtonItem {
    
    
    
    func setActionClosure(_ action: @escaping (UIBarButtonItem) -> Void) {
        let actionWrapperObject = BarButtonItemActionWrapper(action)
        objc_setAssociatedObject(self, &uiBarButtonItemKey, actionWrapperObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.target = self
        self.action = #selector(UIBarButtonItem.invokeActionClosure)
    }
    
    @objc func invokeActionClosure() {
        guard let actionWrapperObject = objc_getAssociatedObject(self, &uiBarButtonItemKey) as? BarButtonItemActionWrapper else {
            return
        }
        actionWrapperObject.action(self)
    }
    
    @discardableResult
    static func make(with title: String, action: @escaping (UIBarButtonItem) -> Void) -> UIBarButtonItem {
        let item = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        item.setActionClosure(action)
        return item
    }
    
    static var flexibleSpace: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }

    static var fixedSpace: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    }

    static func fixedSpaceWithWidth(_ w: CGFloat) -> UIBarButtonItem {
        let item = fixedSpace
        item.width = w
        return item
    }
}

class BarButtonItemActionWrapper: NSObject {
    let action: (UIBarButtonItem) -> Void
    
    init(_ action: @escaping (UIBarButtonItem) -> Void) {
        self.action = action
    }
}

extension String {
    var capitalizedFirst: String {
        guard count > 1 else { return self }
        let first = String(self[self.startIndex]).uppercased()
        return "\(first)\(dropFirst())"
    }
}

public enum AppConfig {
    case debug
    case testFlight
    case appStore

    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

    public static var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    public static var isAppStore: Bool {
        true
//        !isDebug && !AppConfig.isTestFlight
    }
}


// MARK: - Top view controller

public extension UIApplication {
    static var topViewController: UIViewController? {
        guard let rootController = getKeyWindow()?.rootViewController else {
            return nil
        }

        return UIApplication.topViewController(rootController)
    }
}

// MARK: private

private extension UIApplication {
    static func topViewController(_ viewController: UIViewController) -> UIViewController {
        guard let presentedViewController = viewController.presentedViewController else {
            return viewController
        }
        if let navigationController = presentedViewController as? UINavigationController {
            if let visibleViewController = navigationController.visibleViewController {
                return topViewController(visibleViewController)
            }
        } else if let tabBarController = presentedViewController as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return topViewController(selectedViewController)
            }
        }
        return topViewController(presentedViewController)
    }
}

