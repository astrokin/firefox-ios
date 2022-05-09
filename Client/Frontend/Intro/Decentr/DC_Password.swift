// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import SnapKit
import UIKit

final class DC_Password: UIViewController {
    
    enum Mode {
        case createPassword
        case enterPassword
    }
    
    let mode: Mode
    private let didSavePassword: (String) -> ()
    
    init(mode: Mode, didSavePassword: @escaping (String) -> ()) {
        self.mode = mode
        self.didSavePassword = didSavePassword
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Sign in as existing user"
    }
    
    deinit {
        if let token = keyboardChangeFrameObserverToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private var savePasswordButtonBottomConstraint: Constraint? = nil
    
    private lazy var savePasswordButton: UIButton = DC_UI.makeActionButton(text: mode == .createPassword ? "Save password" : "Done",
                                                                           action: { [weak self] in
        if let pass = self?.passwordTextView.plainText {
            DC_Shared_Info.shared.savePassword(pass)
            self?.view.endEditing(true)
            self?.didSavePassword(pass)
        }
    })
    private lazy var titleLabel: UILabel = DC_UI.makeTitleLabel(mode == .createPassword ? "Create a new password" : "Enter password")
    private lazy var descriptionLabel: UILabel = DC_UI.makeDescriptionLabel(mode == .createPassword ? "At least 8 symbols that you’ll use to log in to your account." : "Your Decentr account password")
    private lazy var eyeButton: UIButton = DC_UI.makeEyeButton(action: { [weak self] in
        guard let self = self else { return }
        
        self.eyeButton.isSelected = !self.eyeButton.isSelected
        self.passwordTextView.isProtected = !self.eyeButton.isSelected
    })
    private lazy var passwordTextView: ProtectedTextView = {
        let textView = ProtectedTextView(textColor: DC_UI.primaryColor, onChangeText: { [weak self] text in
            self?.savePasswordButton.isEnabled = self?.isValidInput() ?? false
            self?.eyeButton.isEnabled = text.count > 0
        })
        return textView
    }()
    private lazy var repeatPasswordTextView: ProtectedTextView = {
        let textView = ProtectedTextView(textColor: DC_UI.primaryColor, onChangeText: { [weak self] text in
            self?.savePasswordButton.isEnabled = self?.isValidInput() ?? false
        })
        return textView
    }()
    private lazy var passwordLabel: UILabel = DC_UI.makeFieldLabel("Password")
    private lazy var repeatPasswordLabel: UILabel = DC_UI.makeFieldLabel("Repeat password")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DC_UI.styleVC(self)
        
        DC_UI.layout(on: self, titleLabel: titleLabel, descriptionLabel: descriptionLabel)
        
        switch mode {
        case .createPassword:
            let passwordPlaceholder: UIView = DC_UI.makeTextInputComponent(for: self,
                                                                              topLayoutView: descriptionLabel,
                                                                              fieldLabel: passwordLabel,
                                                                              eyeButton: eyeButton,
                                                                              textView: passwordTextView,
                                                                              height: 80)
            DC_UI.makeTextInputComponent(for: self,
                                            topLayoutView: passwordPlaceholder,
                                            fieldLabel: repeatPasswordLabel,
                                            eyeButton: nil,
                                            textView: repeatPasswordTextView,
                                            height: 80)
        case .enterPassword:
            DC_UI.makeTextInputComponent(for: self,
                                            topLayoutView: descriptionLabel,
                                            fieldLabel: passwordLabel,
                                            eyeButton: eyeButton,
                                            textView: passwordTextView,
                                            height: 80)
        }
        
        
        
        view.addSubview(savePasswordButton)
        savePasswordButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
            make.height.equalTo(DC_UI.buttonHeight)
            self.savePasswordButtonBottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-30).constraint
        }
        
        DC_UI.embedBackButton(on: self)
        
        addKeyboardChangeFrameObserver(willShow: { [weak self] height in
            guard let self = self else { return }
            let btnY = self.view.frame.height - self.savePasswordButton.frame.origin.y - CGFloat(DC_UI.buttonHeight) - 40
            let h = height - btnY
            self.savePasswordButtonBottomConstraint?.update(offset: -h)
            self.view.layoutIfNeeded()
        }, willHide: { [weak self] height in
            self?.savePasswordButtonBottomConstraint?.update(offset: -30)
            self?.view.layoutIfNeeded()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if passwordTextView.canBecomeFirstResponder {
            passwordTextView.becomeFirstResponder()
        }
    }
}

//MARK: - Validation
extension DC_Password {
    
    func isValidInput() -> Bool {
        switch mode {
        case .createPassword:
            let passwdText = passwordTextView.plainText
            let repeatPasswdText = repeatPasswordTextView.plainText
            guard passwdText.count > 7, repeatPasswdText.count > 7 else { return false}
            return passwdText == repeatPasswdText
        case .enterPassword:
            let passwdText = passwordTextView.plainText
            guard passwdText.count > 7 else { return false}
            return true
        }
    }
}
