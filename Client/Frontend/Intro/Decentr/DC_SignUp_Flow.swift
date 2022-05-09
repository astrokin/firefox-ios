// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import Shared
import DecentrAPI

struct SignUpData {
    var seedPhrase: String?
    var address: String? //decentr address
    var firstName: String?
    var lastName: String?
    var bio: String?
    var birthday: Date?
    var gender: String?
    var email: String?
    var currentPassword: String?
    var newPassword: String?
    var newConfirmPassword: String?
    var avatarIndex: Int?
    
    
}

final class DC_SignUp_Flow {
    
    enum Step {
        case seedPhrase
        case email
        case password
        case confirmEmail
        case userSettings
        case trackingSettings
    }
    
    weak var navigationController: UINavigationController?
    var completion: (() -> ())?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func startSignUp() {
        goToStep(.seedPhrase)
        #if !DEBUG
            (UIApplication.shared.delegate as? AppDelegate)?.getProfile(UIApplication.shared).prefs.setInt(1, forKey: PrefsKeys.IntroSeen)
        #endif
    }
    
    private var currentStap: Step!
    private var data: SignUpData = .init()
    
    private func goToStep(_ step: Step) {
        currentStap = step
        
        switch step {
        case .seedPhrase:
            let vc = DC_SignUp_Seed { [weak self] seed in
                self?.data.seedPhrase = seed
                self?.goToStep(.email)
            }
            navigationController?.pushViewController(vc, animated: true)
        case .email:
            let vc = DC_SignUp_Email { [weak self] email in
                self?.data.email = email
                self?.goToStep(.password)
            }
            navigationController?.pushViewController(vc, animated: true)
        case .password:
            let vc = DC_Password(mode: .createPassword) { [weak self] password in
                self?.data.currentPassword = password
                self?.data.newPassword = password
                self?.data.newConfirmPassword = password
                self?.sendRegistration({ [weak self] in
                    self?.goToStep(.confirmEmail)
                })
            }
            navigationController?.pushViewController(vc, animated: true)
        case .confirmEmail:
            let vc = DC_SignUp_Email_Confirm(email: data.email ?? "") { [weak self] in
                self?.goToStep(.userSettings)
            }
            navigationController?.pushViewController(vc, animated: true)
        case .userSettings:
            var _info = data
            _info.currentPassword = DC_Shared_Info.shared.getPassword() //set if changed during settings
            let vc = DC_SignUp_Info(info: _info) { [weak self] info in
                self?.data = info
                self?.goToStep(.trackingSettings)
            }
            navigationController?.pushViewController(vc, animated: true)
        case .trackingSettings:
            let vc = DC_SignUp_Settings(info: data) { [weak self] info in
                self?.data = info
                self?.finishSignUp()
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func sendRegistration(_ completion: @escaping (() -> ())) {
        guard let seed = data.seedPhrase, let pass = data.newPassword, let email = data.email else {
            showLoginError()
            return
        }
        let keyStore = KeyStore(seedPhrase: seed, password: pass)
        guard let keys = try? keyStore.loadKeys() else {
            showLoginError()
            return
        }
        VulcanAPI.register(body: RegisterRequest(address: keys.address, email: email, recaptchaResponse: "", referralCode: "")) { [weak self] data, error in
            if let error = error {
                self?.showLoginError(error)
                return
            } else if let _ = data {
                self?.data.address = keys.address
                completion()
            } else {
                self?.showLoginError()
            }
        }
    }
    
    private func finishSignUp() {
        guard let address = data.address else {
            showLoginError()
            return
        }
        VulcanAPI.trackBrowserInstallation(address: address) { [weak self] data, error in
            if let error = error {
                self?.showLoginError(error)
                return
            } else if let _ = data {
                self?.completion?()
            } else {
                self?.showLoginError()
            }
        }
    }
    
    private func showLoginError(_ error: Error? = nil) {
        let errorMessage = (error as NSError?)?.localizedDescription
        let alert = UIAlertController(title: .CustomEngineFormErrorTitle, message: errorMessage ?? .CustomEngineFormErrorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: .ThirdPartySearchCancelButton, style: .default, handler: { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }))
        navigationController?.present(alert, animated: true)
    }
}


