// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import SnapKit
import UIKit

final class DC_SignUp_Email: UIViewController {

    var email: String?
    private let completion: (String?) -> ()
    
    init(completion: @escaping (String?) -> ()) {
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Create a new account"
    }
    
    deinit {
        if let token = keyboardChangeFrameObserverToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private lazy var titleLabel: UILabel = DC_UI.makeTitleLabel("Connect your email")
    private lazy var descriptionLabel: UILabel = DC_UI.makeDescriptionLabel("We’ll use this email to send the confirmation code, so be sure you have access to it.")
    private lazy var emailLabel: UILabel = DC_UI.makeFieldLabel("Email")
    private var nextButtonBottomConstraint: Constraint? = nil
    private lazy var nextButton: UIButton = DC_UI.makeActionButton(text: "Next", action: { [weak self] in
        self?.completion(self?.textView.plainText)
    })
    private lazy var textView: ProtectedTextView = {
        let textView = ProtectedTextView(textColor: DC_UI.primaryColor, onChangeText: { [weak self] text in
            self?.nextButton.isEnabled = self?.isValidInput() ?? false
        })
        textView.keyboardType = .emailAddress
        textView.isProtected = false
        return textView
    }()
    private lazy var checkbox: UIButton = {
        let button = UIButton()
        let imageOff = UIImage(named: "decentr-checkbox")?.blendedByColor(.lightGray).enlarge(to: CGSize(width: 44, height: 44))
        let imageOn = UIImage(named: "decentr-checkbox")?.enlarge(to: CGSize(width: 44, height: 44))
        button.setImage(imageOff, for: .normal)
        button.setImage(imageOn, for: .selected)
        button.setAction { [weak self] in
            guard let self = self else { return }
            self.checkbox.isSelected = !self.checkbox.isSelected
            self.nextButton.isEnabled = self.isValidInput()
        }
        return button
    }()
    private lazy var termsLabel: UILabel = {
        let label = UILabel()
        label.text = "I have read and agree to"
        label.textColor = DC_UI.primaryColor
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var termsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Terms of use", for: .normal)
        button.contentEdgeInsets = .init(top: 0, left: 6, bottom: 0, right: 6)
        button.setAction { [weak self] in
            let vc = DC_Web(title: button.title(for: .normal) ?? "", url: URL(string: "https://decentr.net/terms.html"))
            self?.present(vc, animated: true, completion: nil)
        }
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHideKeyboardWhenTappedAroundBehaviour()
        
        DC_UI.styleVC(self)
        
        DC_UI.layout(on: self, titleLabel: titleLabel, descriptionLabel: descriptionLabel)
        
        let textInputView = DC_UI.makeTextInputComponent(for: self,
                                                            topLayoutView: descriptionLabel,
                                                            fieldLabel: emailLabel,
                                                            textView: textView,
                                                            height: 80)
        textView.plainText = email ?? ""
        
        view.addSubview(checkbox)
        checkbox.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.left.equalToSuperview().inset(DC_UI.buttonEdgeInset)
            make.top.equalTo(textInputView.snp.bottom).offset(10)
        }
        
        view.addSubview(termsLabel)
        termsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkbox.snp.centerY)
            make.left.equalTo(checkbox.snp.right).offset(5)
        }
        
        view.addSubview(termsButton)
        termsButton.snp.makeConstraints { make in
            make.left.equalTo(checkbox.snp.right)
            make.top.equalTo(termsLabel.snp.bottom).offset(5)
        }
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
            make.height.equalTo(DC_UI.buttonHeight)
            self.nextButtonBottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-30).constraint
        }
        
        DC_UI.embedNavBackButton(on: self)
        
        addKeyboardChangeFrameObserver(willShow: { [weak self] height in
            guard let self = self else { return }
            let btnY = self.view.frame.height - self.nextButton.frame.origin.y - CGFloat(DC_UI.buttonHeight) - 40
            let h = height - btnY
            self.nextButtonBottomConstraint?.update(offset: -h)
            self.view.layoutIfNeeded()
        }, willHide: { [weak self] height in
            self?.nextButtonBottomConstraint?.update(offset: -30)
            self?.view.layoutIfNeeded()
        })
    }
    
    private func isValidInput() -> Bool {
        guard let text = textView.text, text.count > 0, checkbox.isSelected else { return false }
        
        let parts = text.split(separator: "@")
        guard parts.count == 2 else { return false }
        
        let isEmail = parts[0].base.count > 0 && parts[1].base.count > 0 && parts[1].base.contains(".")
        return isEmail
    }
}
