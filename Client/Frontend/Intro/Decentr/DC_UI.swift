// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import SnapKit
import AloeStackView

struct DC_UI {
    
    static let primaryColor: UIColor = UIColor.hexColor("1C1D26")
    static let buttonEdgeInset = 15
    static let buttonHeight = 46
    
    static func styleVC(_ vc: UIViewController, color: UIColor? = nil) {
        //        vc.addHideKeyboardWhenTappedAroundBehaviour()
        
        vc.view.backgroundColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 16, weight: .regular),
                                          .kern: -0.67,
                                          .foregroundColor: color ?? primaryColor]
        vc.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        vc.navigationController?.navigationBar.compactAppearance = appearance
        vc.navigationController?.navigationBar.standardAppearance = appearance
        vc.navigationController?.navigationBar.tintColor = color ?? primaryColor
    }
    
    static func embedNavBackButton(on vc: UIViewController, color: UIColor? = nil) {
        let item = UIBarButtonItem(customView:
                                    makeBackButton(color: color) { [weak vc] in
            if vc?.navigationController?.popViewController(animated: true) == nil {
                vc?.dismiss(animated: true, completion: nil)
            }
        })
        vc.navigationItem.leftBarButtonItem = item
    }
    
    static func embedBackButton(on vc: UIViewController, color: UIColor? = nil) {
        let backButton = makeBackButton(color: color) { [weak vc] in
            if vc?.navigationController?.popViewController(animated: true) == nil {
                vc?.dismiss(animated: true, completion: nil)
            }
        }
        vc.view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(vc.view.safeAreaLayoutGuide.snp.top).inset(15)
            make.leading.equalToSuperview().inset(15)
        }
    }
    
    static func makeAloe(
        axis: NSLayoutConstraint.Axis = .vertical,
        contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    ) -> AloeStackView {
        let aloeStackView = AloeStackView()
        aloeStackView.axis = axis
        aloeStackView.isPagingEnabled = false
        aloeStackView.hidesSeparatorsByDefault = true
        aloeStackView.showsVerticalScrollIndicator = false
        aloeStackView.contentInsetAdjustmentBehavior = .never
        aloeStackView.rowInset = .zero
        aloeStackView.backgroundColor = .clear
        aloeStackView.contentInset = contentInset
        return aloeStackView
    }
    
    static func makeBackButton(color: UIColor? = nil, action: @escaping () -> ()) -> UIButton {
        let button = UIButton()
        let image = UIImage(named: "back-button")?.blendedByColor(color ?? primaryColor)
        button.setImage(image, for: .normal)
        button.setAction {
            action()
        }
        return button
    }
    
    static func makeTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = primaryColor
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        return label
    }
    
    static func makeDescriptionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.textColor = primaryColor
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }
    
    static func makeFieldLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.hexColor("929297")
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }
    
    static func makeActionButton(text: String, action: @escaping () -> ()) -> UIButton {
        let button = UIButton()
        button.setTitleColor(UIColor.hexColor("B6B7BA"), for: .disabled)
        button.setBackgroundColor(UIColor.hexColor("F6F6F7"), forState: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundColor(UIColor.hexColor("4F80FF"), forState: .normal)
        button.setTitle(text, for: .normal)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.isEnabled = false
        button.setAction {
            action()
        }
        return button
    }
    
    static func makeEyeButton(action: @escaping () -> ()) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "Eye Open"), for: .normal)
        button.setImage(UIImage(named: "Eye Open")?.blendedByColor(.lightGray), for: .selected)
        button.setAction {
            action()
        }
        return button
    }
    
    static func makeSmallButton(image: String, title: String, action: @escaping () -> ()) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: image), for: .normal)
        button.setTitle(title, for: .normal)
        button.setTitleColor(primaryColor, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.contentEdgeInsets = .init(top: 0, left: 6, bottom: 0, right: 6)
        button.setAction {
            action()
        }
        return button
    }
}

//MARK: - Layout

extension DC_UI {
    
    static func layout(on vc: UIViewController, titleLabel: UILabel, descriptionLabel: UILabel) {
        vc.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(buttonEdgeInset)
            make.top.equalTo(vc.view.safeAreaLayoutGuide.snp.top).inset(10)
        }
        
        vc.view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(buttonEdgeInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(7)
        }
    }
    
    @discardableResult
    static func makeTextInputComponent(
        for vc: UIViewController? = nil,
        topLayoutView: UIView? = nil,
        fieldLabel: UILabel,
        eyeButton: UIButton? = nil,
        textView: UITextView,
        height: CGFloat = 180
    ) -> UIView {
        let textPlaceholder: UIView = .init()
        textPlaceholder.backgroundColor = UIColor.hexColor("F6F6F7")
        textPlaceholder.layer.cornerRadius = 12
        textPlaceholder.clipsToBounds = true
        if let vc = vc, let top = topLayoutView {
            vc.view.addSubview(textPlaceholder)
            textPlaceholder.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(buttonEdgeInset)
                make.top.equalTo(top.snp.bottom).offset(15)
            }
        }
        textPlaceholder.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        
        textPlaceholder.addSubview(fieldLabel)
        fieldLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }
        
        if let eyeButton = eyeButton {
            textPlaceholder.addSubview(eyeButton)
            eyeButton.snp.makeConstraints { make in
                make.top.right.equalToSuperview().inset(16)
                make.width.height.equalTo(24)
            }
        }
        
        textPlaceholder.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
            make.top.equalTo(fieldLabel.snp.bottom).offset(5)
        }
        return textPlaceholder
    }
    
    
}

extension UIActivityIndicatorView {
    static func makeWhiteLarge() -> UIActivityIndicatorView {
        if #available(iOS 13, *) {
            let view = UIActivityIndicatorView(style: .large)
            view.tintColor = .white
            return view
        } else {
            return UIActivityIndicatorView(style: .whiteLarge)
        }
    }

    static func makeGray() -> UIActivityIndicatorView {
        if #available(iOS 13, *) {
            let view = UIActivityIndicatorView(style: .medium)
            view.tintColor = .gray
            return view
        } else {
            return UIActivityIndicatorView(style: .gray)
        }
    }
}
