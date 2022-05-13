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
    var avatarIndex: Int?
    
    init(seedPhrase: String? = nil, address: String? = nil, firstName: String? = nil, lastName: String? = nil, bio: String? = nil, birthday: Date? = nil, gender: String? = nil, email: String? = nil, avatarIndex: Int? = nil) {
        self.seedPhrase = seedPhrase
        self.address = address
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
        self.birthday = birthday
        self.gender = gender
        self.email = email
        self.avatarIndex = avatarIndex
    }
    
    init(account: DecentrAccount) {
        self.seedPhrase = nil
        self.address = account.baseAccount?.account?.address
        self.firstName = account.apiProfile?.firstName
        self.lastName = account.apiProfile?.lastName
        self.bio = account.apiProfile?.bio
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-DD"
        if let dateString = account.apiProfile?.birthday {
            self.birthday = df.date(from: dateString)
        } else {
            self.birthday = nil
        }
        self.gender = account.apiProfile?.gender
        self.email = account.apiProfile?.emails?.first
        self.avatarIndex = 1
    }
}

final class DC_SignUp_Flow {
    
    enum Step {
        case seedPhrase
        case email
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
                self?.sendRegistration { [weak self] in
                    self?.goToStep(.confirmEmail)
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        case .confirmEmail:
            let vc = DC_SignUp_Email_Confirm(email: data.email ?? "") { [weak self] in
                self?.goToStep(.userSettings)
            }
            navigationController?.pushViewController(vc, animated: true)
        case .userSettings:
            let vc = DC_SignUp_Info(info: data) { [weak self] info in
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
        guard let seed = data.seedPhrase, let email = data.email else {
            showLoginError()
            return
        }
        let keyStore = KeyStore(seedPhrase: seed)
        guard let keys = try? keyStore.loadKeys() else {
            showLoginError()
            return
        }
        VulcanAPI.register(body: RegisterRequest(address: keys.address, email: email)) { [weak self] data, error in
            if let respErr = error as? DecentrAPI.ErrorResponse {
                switch respErr {
                case let .error(code, data, error):
                    switch code {
                    case 409:
                        self?.showLoginError("A wallet has already been created for this email or wallet address")
                    case 400:
                        self?.showLoginError("Invalid email")
                    case 429:
                        self?.showLoginError("Too many requests")
                    default:
                        self?.showLoginError(error)
                    }
                }
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
            } else if let _ = data, let seed = self?.data.seedPhrase {
                DC_Shared_Info.shared.savePlainSeedPhrase(seed)
                self?.completion?()
                #if !DEBUG
                    (UIApplication.shared.delegate as? AppDelegate)?.getProfile(UIApplication.shared).prefs.setInt(1, forKey: PrefsKeys.IntroSeen)
                #endif
            } else {
                self?.showLoginError()
            }
        }
    }
    
    private func showLoginError(_ error: Error? = nil) {
        showLoginError((error as NSError?)?.localizedDescription)
    }
    
    private func showLoginError(_ errorMessage: String?) {
        let alert = UIAlertController(title: .CustomEngineFormErrorTitle, message: errorMessage ?? .CustomEngineFormErrorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: .ThirdPartySearchCancelButton, style: .default, handler: { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }))
        navigationController?.present(alert, animated: true)
    }
}


