// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Foundation
import UIKit
import SnapKit
import Shared

class IntroScreenWelcomeView: UIView, CardTheme {
    // Private vars
    private var fxTextThemeColour: UIColor {
        // For dark theme we want to show light colours and for light we want to show dark colours
        return theme == .dark ? .white : .black
    }
    private var fxBackgroundThemeColour: UIColor {
        return theme == .dark ? UIColor.Decentr.DarkGrey10 : .white
    }
    // Orientation independent screen size
    private let screenSize = DeviceInfo.screenSizeOrientationIndependent()
    // Views
    private lazy var titleImageViewPage1: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "tour-Welcome"))
        imgView.contentMode = .center
        imgView.clipsToBounds = true
        return imgView
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = .CardTitleWelcome
        label.textColor = fxTextThemeColour
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "signUpOnboardingButton"
        button.layer.cornerRadius = 12
        button.backgroundColor = .white
        button.setTitle(.IntroSignUpButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(UIColor.Decentr.BlackText, for: .normal)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "signInOnboardingButton"
        button.layer.cornerRadius = 12
        button.backgroundColor = .white
        button.setTitle(.IntroSignInButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(UIColor.Decentr.BlackText, for: .normal)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    private(set) lazy var startBrowsingButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.setTitle(.StartBrowsingButtonTitle, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.accessibilityIdentifier = "startBrowsingButtonSyncView"
        return button
    }()
    
    // Helper views
    let main2panel = UIStackView()
    let imageHolder = UIView()
    let bottomHolder = UIView()
    // Closure delegates
    var signUpClosure: (() -> Void)?
    var signInClosure: (() -> Void)?
    var startBrowsing: (() -> Void)?
    // Basic variables
    private var currentPage: Int32 = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialViewSetup()
        TelemetryWrapper.recordEvent(category: .action, method: .view, object: .welcomeScreenView)
    }
    
    // MARK: View setup
    private func initialViewSetup() {
        // Background colour setup
        backgroundColor = .clear
        // View setup
        main2panel.axis = .vertical
        main2panel.distribution = .fillEqually
    
        addSubview(main2panel)
        main2panel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(safeArea.top)
            make.bottom.equalTo(safeArea.bottom)
        }
        
        main2panel.addArrangedSubview(imageHolder)
        imageHolder.addSubview(titleImageViewPage1)
        titleImageViewPage1.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        main2panel.addArrangedSubview(bottomHolder)
        [titleLabel, signUpButton, signInButton, startBrowsingButton].forEach {
             bottomHolder.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalToSuperview()
        }
        
        let buttonEdgeInset = 15
        let buttonHeight = 46
        let buttonSpacing = 16
        
        signUpButton.addTarget(self, action: #selector(showSignUpFlow), for: .touchUpInside)
        signUpButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(buttonEdgeInset)
            make.bottom.equalTo(signInButton.snp.top).offset(-buttonSpacing)
            make.height.equalTo(buttonHeight)
        }
        signInButton.addTarget(self, action: #selector(showEmailLoginFlow), for: .touchUpInside)
        signInButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(buttonEdgeInset)
            make.bottom.equalTo(startBrowsingButton.snp.top).offset(-buttonSpacing)
            make.height.equalTo(buttonHeight)
        }
        startBrowsingButton.addTarget(self, action: #selector(startBrowsingAction), for: .touchUpInside)
        startBrowsingButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(buttonEdgeInset)
            // On large iPhone screens, bump this up from the bottom
            let offset: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 20 : (screenSize.height > 800 ? 60 : 20)
            make.bottom.equalToSuperview().inset(offset)
            make.height.equalTo(buttonHeight)
        }
    }

    @objc func showEmailLoginFlow() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .dismissedOnboardingEmailLogin, extras: ["slide-num": currentPage])
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .welcomeScreenSignIn)
        signInClosure?()
    }

    @objc func showSignUpFlow() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .dismissedOnboardingSignUp, extras: ["slide-num": currentPage])
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .welcomeScreenSignUp)
        signUpClosure?()
    }
    
    @objc private func startBrowsingAction() {
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .dismissedOnboarding, extras: ["slide-num": 1])
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .syncScreenStartBrowse)
        startBrowsing?()
    }
}
