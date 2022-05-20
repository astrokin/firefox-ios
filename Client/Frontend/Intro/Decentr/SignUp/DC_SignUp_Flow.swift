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
                if let seed = seed {
                    DC_Shared_Info.shared.savePlainSeedPhrase(seed)
                }
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
                self?.checkNewAddressCreatedOnBlockchain(retryCount: 10, success: {
                    UIApplication.getKeyWindow()?.removeLoader()
                    self?.goToStep(.userSettings)
                }, failed: { [weak self] in
                    UIApplication.getKeyWindow()?.removeLoader()
                    self?.showLoginError()
                })
            }
            navigationController?.pushViewController(vc, animated: true)
        case .userSettings:
            let vc = DC_SignUp_Info(info: data) { [weak self] info in
                self?.data = info
                UIApplication.getKeyWindow()?.showLoader()
                self?.updateUserProfile(success: {
                    self?.finishSignUp()
                }, failed: {
                    DC_Shared_Info.shared.purge()
                    self?.showLoginError()
                    UIApplication.getKeyWindow()?.removeLoader()
                    self?.navigationController?.popToRootViewController(animated: true)
                })
//                self?.goToStep(.trackingSettings)
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
    
    private func checkNewAddressCreatedOnBlockchain(retryCount: Int, success: @escaping (() -> ()), failed: @escaping (() -> ())) {
        guard retryCount > 0, let address = data.address else {
            failed()
            return
        }
        DcntrAPI.ProfilesAPI.getCheckAddress(address: address) { [weak self] data, error in
            if error != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                    self?.checkNewAddressCreatedOnBlockchain(retryCount: retryCount - 1, success: success, failed: failed)
                }
                return
            }
            if data == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                    self?.checkNewAddressCreatedOnBlockchain(retryCount: retryCount - 1, success: success, failed: failed)
                }
                return
            } else if let data = data, data.account?.account_number != nil {
                success()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                    self?.checkNewAddressCreatedOnBlockchain(retryCount: retryCount - 1, success: success, failed: failed)
                }
            }
        }
    }
    
    private func sendRegistration(_ completion: @escaping (() -> ())) {
        DispatchQueue.global(qos: .utility).async {
            guard let seed = self.data.seedPhrase, let email = self.data.email else {
                self.showLoginError()
                return
            }
            let keyStore = KeyStore(seedPhrase: seed)
            guard let keys = try? keyStore.loadKeys() else {
                self.showLoginError()
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
                    DispatchQueue.main.async {
                        completion()
                    }
                } else {
                    self?.showLoginError()
                }
            }
        }
    }
    
    private func updateUserProfile(success: @escaping (() -> ()), failed: @escaping (() -> ())) {
        guard let email = data.email else {
            failed()
            return
        }
        var birthday: String? = nil
        if let bd = data.birthday {
            let df = DateFormatter()
            df.dateFormat = "YYYY-MM-DD"
            birthday = df.string(from: bd)
        }
        let body = PDVPrifileRequest(version: "v1", pdv: [
            PDVProfile(avatar: nil,
                       bio: data.bio,
                       birthday: birthday,
                       emails: [email],
                       gender: data.gender,
                       firstName: data.firstName,
                       lastName: data.lastName)
            
        ])
        
        let reqBuilder = CerberusAPI.PDVAPI.saveProfileWithRequestBuilder(body: body)
        reqBuilder.executeSignRequest { response in
            success()
        } failed: { error in
            failed()
        }
    }
    
    private func finishSignUp() {
        guard let address = data.address else {
            showLoginError()
            return
        }
        VulcanAPI.trackBrowserInstallation(address: address) { [weak self] data, error in
            //ignore any error for this api call
            UIApplication.getKeyWindow()?.removeLoader()
            self?.completion?()
            #if !DEBUG
                (UIApplication.shared.delegate as? AppDelegate)?.getProfile(UIApplication.shared).prefs.setInt(1, forKey: PrefsKeys.IntroSeen)
            #endif
        }
    }
    
    private func showLoginError(_ error: Error? = nil) {
        showLoginError((error as NSError?)?.localizedDescription)
    }
    
    private func showLoginError(_ errorMessage: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: .CustomEngineFormErrorTitle, message: errorMessage ?? .CustomEngineFormErrorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: .ThirdPartySearchCancelButton, style: .default, handler: { [weak self] _ in
                self?.navigationController?.popToRootViewController(animated: true)
            }))
            self.navigationController?.present(alert, animated: true)
        }
    }
}


