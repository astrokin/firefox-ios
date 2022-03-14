// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import SnapKit
import UIKit
import CHIOTPField

final class DC_SignUp_Email_Confirm: UIViewController {
    
    private let completion: () -> ()
    private let email: String
    
    init(email: String, completion: @escaping () -> ()) {
        self.email = email
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
        
        title = ""
    }
    
    deinit {
        timer?.invalidate()
        if let token = keyboardChangeFrameObserverToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    private var timer: Timer?
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private lazy var icon: UIImageView = .init(image: UIImage(named: "Email confirmation wait"))
    
    private lazy var field: CHIOTPFieldOne = {
        let field = CHIOTPFieldOne(frame: .zero)
        field.numberOfDigits = 6
        field.cornerRadius = 4
        field.spacing = 4
        field.boxBackgroundColor = UIColor.hexColor("F6F6F7")
        field.borderColor = .clear
        field.boxPlaceholderColor = UIColor.hexColor("F6F6F7")
        return field
    }()
    
    private lazy var resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Resend confirmation code", for: .normal)
        button.setTitleColor(.systemGray, for: .disabled)
        button.isEnabled = false
        button.setAction { [weak self] in
            self?.startTimer()
        }
        return button
    }()
    
    private var nextButtonBottomConstraint: Constraint? = nil
    private lazy var nextButton: UIButton = DC_UI.makeActionButton(text: "Confirm", action: { [weak self] in
        self?.completion()
    })
    
    private lazy var resendLabel: UILabel = {
        let hint2 = DC_UI.makeDescriptionLabel("")
        hint2.textAlignment = .center
        return hint2
    }()
    
    private var resendWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHideKeyboardWhenTappedAroundBehaviour()
        
        DC_UI.styleVC(self)
        DC_UI.embedBackButton(on: self)
        
        view.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(30)
            make.centerX.equalToSuperview()
        }
        
        let title = DC_UI.makeTitleLabel("Please confirm your email")
        title.textAlignment = .center
        view.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        let subtitle = DC_UI.makeDescriptionLabel("We’ve send you the confirmation letter to the \(email) email.")
        subtitle.textAlignment = .center
        view.addSubview(subtitle)
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
        }
        
        let hint = DC_UI.makeFieldLabel("Just want to ensure we deal with real people.")
        hint.textAlignment = .center
        view.addSubview(hint)
        hint.snp.makeConstraints { make in
            make.top.equalTo(subtitle.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
        }
        
        view.addSubview(field)
        field.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
            make.top.equalTo(hint.snp.bottom).offset(30)
        }
        
        
        view.addSubview(resendLabel)
        resendLabel.snp.makeConstraints { make in
            make.top.equalTo(field.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
        }
        
        view.addSubview(resendButton)
        resendButton.snp.makeConstraints { make in
            make.top.equalTo(resendLabel.snp.bottom).offset(10)
            make.height.equalTo(44)
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
        }
        
        nextButton.isEnabled = false
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
            make.height.equalTo(DC_UI.buttonHeight)
            self.nextButtonBottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-30).constraint
        }
        
        startTimer()
        
        keyboardChangeFrameObserverToken = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                                                                  object: nil,
                                                                                  queue: .main,
                                                                                  using: { [weak self] info in
            if (info.object as? UITextField) == self?.field {
                if let text = self?.field.text, text.count == 6 {
                    self?.nextButton.isEnabled = true
                }
            }
        })
    }
    
    private func startTimer() {
        tick = 0
        resendButton.isEnabled = false
        
        timer = Timer(timeInterval: 1.0, repeats: true, block: { [weak self] _ in
            self?.onTimerTick()
        })

        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    private var tick: Int = 0
    
    private func onTimerTick() {
        tick += 1
        
        if tick == 60 {
            resendButton.isEnabled = true
            timer?.invalidate()
            timer = nil
            resendLabel.text = "Didn’t get the code or couldn’t find it?"
        } else {
            resendLabel.text = "We’ve resend the code to your email. You can get the new one in \(60 - tick)"
        }
    }
}
