// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Foundation
import UIKit
import Shared
import SnapKit

class IntroViewController: UIViewController, OnViewDismissable {
    var onViewDismissed: (() -> Void)? = nil
    // private var
    // Private views
    private lazy var welcomeCard: IntroScreenWelcomeView = {
        let welcomeCardView = IntroScreenWelcomeView()
        welcomeCardView.translatesAutoresizingMaskIntoConstraints = false
        welcomeCardView.clipsToBounds = true
        return welcomeCardView
    }()
    
    // Closure delegate
    var didFinishClosure: ((IntroViewController?, FxAPageType?) -> Void)?
    private var signUpFlow: DC_SignUp_Flow?
    private var signInFlow: DC_SignIn_Flow?
    
    // MARK: Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bg = UIImageView(image: UIImage(named: "decentr-background"))
        bg.contentMode = .scaleAspectFill
        view.addSubview(bg)
        bg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(welcomeCard)
        NSLayoutConstraint.activate([
            welcomeCard.topAnchor.constraint(equalTo: view.topAnchor),
            welcomeCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            welcomeCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            welcomeCard.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Start browsing button action
        welcomeCard.startBrowsing = {
            self.didFinishClosure?(self, nil)
        }
        // Sign in button closure
        welcomeCard.signInClosure = { [weak self] in
            self?.signInFlow = DC_SignIn_Flow(navigationController: self?.navigationController)
            self?.signInFlow?.startSignIn()
            self?.signInFlow?.completion = { [weak self] in
                self?.didFinishClosure?(self, nil)
            }
        }
        // Sign up button closure
        welcomeCard.signUpClosure = { [weak self] in
            self?.signUpFlow = DC_SignUp_Flow(navigationController: self?.navigationController)
            self?.signUpFlow?.startSignUp()
            self?.signUpFlow?.completion = { [weak self] in
                self?.didFinishClosure?(self, nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        onViewDismissed?()
        onViewDismissed = nil
    }
}

// MARK: UIViewController setup
extension IntroViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // This actually does the right thing on iPad where the modally
        // presented version happily rotates with the iPad orientation.
        return .portrait
    }
}
