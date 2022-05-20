// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared
import DecentrAPI

final class DC_SignIn_Flow {
    
    enum Step {
        case scanQR
        case enterSeed
        case enterPassword
    }
    
    weak var navigationController: UINavigationController?
    var completion: ((DecentrAccount) -> ())?
    
    var enteredSeed: String?
    var decryptedSeed: String?
    var encryptedSeedFromQR: String?
    var password: String?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func startSignIn() {
        goToStep(.scanQR)
    }
    
    private func goToStep(_ step: Step) {
        switch step {
        case .scanQR:
            let vc = DC_Login()
            vc.qrCodeScanner.didScanQRCodeWithURL = { url in
            }
            vc.qrCodeScanner.didScanQRCodeWithText = { [weak self] seed in
                var components = URLComponents(string: seed)
                components?.scheme = "decentr"
                if let enc = components?.queryItems?.first(where: { $0.name == "encryptedSeed" })?.value {
                    self?.encryptedSeedFromQR = enc
                    self?.goToStep(.enterPassword)
                }
            }
            vc.completion = { [weak self] in
                self?.goToStep(.enterSeed)
            }
            navigationController?.pushViewController(vc, animated: true)
        case .enterSeed:
            let vc = DC_Enter_Seed()
            vc.seedPhrase = nil
            vc.completion = { [weak self] seed in
                self?.enteredSeed = seed
                DispatchQueue.global(qos: .utility).async {
                    if let enteredSeed = self?.enteredSeed {
                        do {
                            let keyStore = KeyStore(seedPhrase: enteredSeed)
                            let keys = try keyStore.loadKeys()
                            self?.getProfile(keys, onSuccess: { _ in
                                DC_Shared_Info.shared.savePlainSeedPhrase(enteredSeed)
                            })
                        } catch {
                            self?.showLoginError()
                        }
                    }
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        case .enterPassword:
            let vc = DC_Password(mode: .enterPassword, didSavePassword: { [weak self] pass in
                DispatchQueue.global(qos: .utility).async {
                    if let encryptedSeedFromQR = self?.encryptedSeedFromQR {
                        do {
                            let keyStore = KeyStore(encryptedSeed: encryptedSeedFromQR, password: pass)
                            let keys = try keyStore.loadKeys()
                            self?.getProfile(keys, onSuccess: { _ in
                                DC_Shared_Info.shared.saveEncryptedSeedPhrase(encryptedSeedFromQR)
                            })
                        } catch {
                            self?.showLoginError()
                        }
                    } else {
                        self?.showLoginError()
                    }
                }
            })
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

private extension DC_SignIn_Flow {
    
    private func showLoginError(_ error: Error? = nil) {
        DispatchQueue.main.async {
            let errorMessage = (error as NSError?)?.localizedDescription
            let alert = UIAlertController(title: .CustomEngineFormErrorTitle, message: errorMessage ?? .CustomEngineFormErrorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: .ThirdPartySearchCancelButton, style: .default, handler: { [weak self] _ in
                self?.navigationController?.popToRootViewController(animated: true)
                self?.startSignIn()
            }))
            self.navigationController?.present(alert, animated: true)
        }
    }
    
    private func getProfile(_ keys: KeyStore.Keys, onSuccess: @escaping ((String?) -> ())) {
        DispatchQueue.main.async {
            UIApplication.getKeyWindow()?.showLoader()
            DC_Shared_Info.shared.refreshAccountInfo(address: keys.address) { [weak self] result in
                UIApplication.getKeyWindow()?.removeLoader()
                switch result {
                case let .failure(error):
                    self?.showLoginError(error)
                case let .success(account):
                    VulcanAPI.trackBrowserInstallation(address: keys.address) { [weak self] data, error in
                        //ignore errors
                        onSuccess(DC_Shared_Info.shared.getAccount().apiProfile?.firstName)
                        self?.completion?(account)
                        #if !DEBUG
                            (UIApplication.shared.delegate as? AppDelegate)?.getProfile(UIApplication.shared).prefs.setInt(1, forKey: PrefsKeys.IntroSeen)
                        #endif
                    }
                }
            }
        }
    }
}
