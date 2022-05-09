// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import SnapKit

final class DC_Enter_Seed: UIViewController {

    var seedPhrase: String?
    var completion: ((String) -> ())?
    
    init() {
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
    
    private lazy var scanQRButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(DC_UI.primaryColor, for: .normal)
        button.setTitle("Scan QR code", for: .normal)
        button.setAction { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return button
    }()
    
    private var importUserButtonBottomConstraint: Constraint? = nil
    
    private lazy var importUserButton: UIButton = DC_UI.makeActionButton(text: "Import User") { [weak self] in
        if let seed = self?.textView.plainText, Self.isValidSeed(seed) {
            self?.completion?(seed)
        }
    }
    
    private lazy var titleLabel: UILabel = DC_UI.makeTitleLabel("Import with seed phrase")
    private lazy var descriptionLabel: UILabel = DC_UI.makeDescriptionLabel("To find QR code go to user settings in Decentr or enter seed phrase manually.")
    private lazy var seedLabel: UILabel = DC_UI.makeFieldLabel("Your seed phrase")
    private lazy var eyeButton: UIButton = DC_UI.makeEyeButton(action: { [weak self] in
        guard let self = self else { return }
        
        self.eyeButton.isSelected = !self.eyeButton.isSelected
        self.textView.isProtected = !self.eyeButton.isSelected
    })
    private lazy var textView: ProtectedTextView = {
        let textView = ProtectedTextView(textColor: DC_UI.primaryColor, onChangeText: { [weak self] text in
            self?.importUserButton.isEnabled = Self.isValidSeed(text)
            self?.eyeButton.isEnabled = text.count > 0
        })
        if let text = seedPhrase, Self.isValidSeed(text) {
            textView.plainText = text
            textView.isProtected = true
            importUserButton.isEnabled = true
        }
        return textView
    }()
    
    private static func isValidSeed(_ enteredPlainSeed: String) -> Bool {
        enteredPlainSeed.removingMultipleSpaces()
            .split(separator: " ")
            .filter({ $0.count > 2 })
            .count == 24
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DC_UI.styleVC(self)

        DC_UI.layout(on: self, titleLabel: titleLabel, descriptionLabel: descriptionLabel)
        
        DC_UI.makeTextInputComponent(
            for: self,
               topLayoutView: descriptionLabel,
               fieldLabel: seedLabel,
               eyeButton: eyeButton,
               textView: textView
        )
        
        view.addSubview(scanQRButton)
        scanQRButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
            make.height.equalTo(DC_UI.buttonHeight)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(30)
        }
        
        view.addSubview(importUserButton)
        importUserButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
            make.height.equalTo(DC_UI.buttonHeight)
            self.importUserButtonBottomConstraint = make.bottom.equalTo(self.scanQRButton.snp.top).offset(-16).constraint
        }
        
        DC_UI.embedBackButton(on: self)
        
        addKeyboardChangeFrameObserver(willShow: { [weak self] height in
            guard let self = self else { return }
            let btnY = self.view.frame.height - self.importUserButton.frame.origin.y - CGFloat(DC_UI.buttonHeight) - 32
            let h = height - btnY
            self.importUserButtonBottomConstraint?.update(offset: -h)
            self.view.layoutIfNeeded()
        }, willHide: { [weak self] height in
            self?.importUserButtonBottomConstraint?.update(offset: -16)
            self?.view.layoutIfNeeded()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if seedPhrase == nil, textView.canBecomeFirstResponder {
            textView.becomeFirstResponder()
        }
    }
}

extension String {
    
    func removingMultipleSpaces() -> String {
        let doubleSpace = "  "
        if contains(doubleSpace) {
            return replacingOccurrences(of: doubleSpace, with: " ").removingMultipleSpaces()
        }
        return self
    }
    
    func removeLeadingZero() -> String {
        replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
    }
}
