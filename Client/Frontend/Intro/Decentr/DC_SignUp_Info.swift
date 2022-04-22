// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import AloeStackView
import SnapKit
import UIKit

final class DC_SignUp_Info: UIViewController {
    
    private let completion: (SignUpData) -> ()
    private var info: SignUpData
    
    init(info: SignUpData, completion: @escaping (SignUpData) -> ()) {
        self.info = info
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
        
        title = "User settings"
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private var nextButtonBottomConstraint: Constraint? = nil
    private lazy var nextButton: UIButton = DC_UI.makeActionButton(text: "Save", action: { [weak self] in
        if var info = self?.info {
            info.avatarIndex = self?.picSelector.selectedIndex
            self?.completion(info)
        }
    })
    private lazy var aloeStackView: AloeStackView = DC_UI.makeAloe()
    
    private lazy var picSelector: ProfilePicSelector = {
       let view = ProfilePicSelector(selectedIndex: 1)
        return view
    }()
    
    private lazy var firstName: ProtectedTextView = makeInput()
    private lazy var lastName: ProtectedTextView = makeInput()
    private lazy var bio: ProtectedTextView = makeInput()
    private lazy var birthDate: ProtectedTextView = makeInput()
    private lazy var gender: ProtectedTextView = makeInput()
    private lazy var email: ProtectedTextView = makeInput()
    
    private func makeInput() -> ProtectedTextView {
        let field = ProtectedTextView(textColor: DC_UI.primaryColor, onChangeText: { [weak self] text in
            self?.nextButton.isEnabled = self?.isValidInput() ?? false
        })
        field.keyboardType = .emailAddress
        field.isProtected = false
        return field
    }
    
    private lazy var currentPassword: ProtectedTextView = {
        let field = ProtectedTextView(textColor: DC_UI.primaryColor, onChangeText: { [weak self] text in
            self?.nextButton.isEnabled = self?.isValidInput() ?? false
        })
        return field
    }()
    
    private lazy var newPassword: ProtectedTextView = {
        let field = ProtectedTextView(textColor: DC_UI.primaryColor, onChangeText: { [weak self] text in
            self?.nextButton.isEnabled = self?.isValidInput() ?? false
        })
        return field
    }()
    
    private lazy var newRepeatPassword: ProtectedTextView = {
        let field = ProtectedTextView(textColor: DC_UI.primaryColor, onChangeText: { [weak self] text in
            self?.nextButton.isEnabled = self?.isValidInput() ?? false
        })
        return field
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DC_UI.styleVC(self)
        DC_UI.embedBackButton(on: self)
        
        view.addSubview(aloeStackView)
        aloeStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
        }
        
        let title = DC_UI.makeTitleLabel("Your profile picture")
        aloeStackView.addRow(title)
        aloeStackView.setInset(forRow: title, inset: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        let subtitle = DC_UI.makeDescriptionLabel("It will appear on your posts and comments across Decentr.")
        aloeStackView.addRow(subtitle)
        aloeStackView.setInset(forRow: subtitle, inset: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        aloeStackView.addRow(picSelector)
        picSelector.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        let title2 = DC_UI.makeTitleLabel("Personal info")
        aloeStackView.addRow(title2)
        aloeStackView.setInset(forRow: title2, inset: .init(top: 15, left: 0, bottom: 0, right: 0))
        
        let subtitle2 = DC_UI.makeDescriptionLabel("Something that will allow others to identifying you better than a simple image.")
        aloeStackView.addRow(subtitle2)
        aloeStackView.setInset(forRow: subtitle2, inset: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        let fn = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("First name"), textView: firstName, height: 80)
        aloeStackView.addRow(fn)
        
        let ln = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("Last name"), textView: lastName, height: 80)
        aloeStackView.addRow(ln)
        
        let bio = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("Your bio"), textView: self.bio, height: 80)
        aloeStackView.addRow(bio)
        
        let gen = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("Gender"), textView: gender, height: 80)
        aloeStackView.addRow(gen)
        
        let title3 = DC_UI.makeTitleLabel("Connected email")
        aloeStackView.addRow(title3)
        aloeStackView.setInset(forRow: title3, inset: .init(top: 15, left: 0, bottom: 0, right: 0))
        
        let subtitle3 = DC_UI.makeDescriptionLabel("We’ll use this email to sent the confirmation code, so be sure you have an access to it.")
        aloeStackView.addRow(subtitle3)
        aloeStackView.setInset(forRow: subtitle3, inset: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        let email = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("Email"), textView: self.email, height: 80)
        aloeStackView.addRow(email)
        
        let title4 = DC_UI.makeTitleLabel("Set new password")
        aloeStackView.addRow(title4)
        aloeStackView.setInset(forRow: title4, inset: .init(top: 15, left: 0, bottom: 0, right: 0))
        
        let subtitle4 = DC_UI.makeDescriptionLabel("At least 8 symbols with 1 capital letter and 1 special symbol that you’ll use to log in to your account or lock/unlock it.")
        aloeStackView.addRow(subtitle4)
        aloeStackView.setInset(forRow: subtitle4, inset: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        let cp = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("Old password"), textView: currentPassword, height: 80)
        aloeStackView.addRow(cp)
        
        let np = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("New password"), textView: newPassword, height: 80)
        aloeStackView.addRow(np)
        
        let npr = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("New password confirmation"), textView: newRepeatPassword, height: 80)
        aloeStackView.addRow(npr)
        
        aloeStackView.setInset(forRows: [fn, ln, bio, gen, email, picSelector, cp, np, npr], inset: .init(top: 7, left: 0, bottom: 0, right: 0))
        
        firstName.plainText = info.firstName ?? ""
        lastName.plainText = info.lastName ?? ""
        self.bio.plainText = info.bio ?? ""
        gender.plainText = info.gender ?? ""
        self.email.plainText = info.email ?? ""
        currentPassword.plainText = info.currentPassword ?? ""
        
        nextButton.isEnabled = false
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
            make.height.equalTo(DC_UI.buttonHeight)
            self.nextButtonBottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-30).constraint
        }
        
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
        return false
    }
}

final class ProfilePicSelector: UIView {
    
    var selectedIndex: Int
    private var buttons: [UIButton] = []
    
    init(selectedIndex: Int) {
        self.selectedIndex = selectedIndex
        
        super.init(frame: .zero)
        
        addSubview(aloeStackView)
        aloeStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.buttons = Array(1 ... 12).map({ index in
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "user-avatar-\(index)"), for: .normal)
            button.setImage(UIImage(), for: .normal)
            button.setImage(UIImage(named: "avatar-checkmark"), for: .selected)
            button.contentVerticalAlignment = .bottom
            button.contentHorizontalAlignment = .right
            button.setAction { [weak self, weak button] in
                self?.buttons.forEach({ $0.isSelected = false })
                button?.isSelected = true
                self?.selectedIndex = button?.tag ?? 0
            }
            button.isSelected = index == selectedIndex
            button.tag = index
            button.snp.makeConstraints { make in
                make.width.height.equalTo(40)
            }
            return button
        })
        
        self.buttons.forEach { button in
            self.aloeStackView.addRow(button)
            if button.tag > 1 {
                self.aloeStackView.setInset(forRow: button, inset: .init(top: 0, left: 5, bottom: 0, right: 0))
            }
        }
        
        
    }
    private lazy var aloeStackView: AloeStackView = DC_UI.makeAloe(axis: .horizontal, contentInset: .zero)
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
