// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

final class DC_SignIn_Flow {
    
    enum Step {
        case scanQR
        case enterSeed(String?)
        case enterPassword
    }
    
    weak var navigationController: UINavigationController?
    var completion: (() -> ())?
    
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
            vc.qrCodeScanner.didScanQRCodeWithText = { [weak self] text in
                self?.goToStep(.enterSeed(text))
            }
            vc.completion = { [weak self] in
                self?.goToStep(.enterSeed(nil))
            }
            navigationController?.pushViewController(vc, animated: true)
        case let .enterSeed(seed):
            let vc = DC_Enter_Seed()
            vc.seedPhrase = seed
            vc.completion = { [weak self] in
                self?.goToStep(.enterPassword)
            }
            navigationController?.pushViewController(vc, animated: true)
        case .enterPassword:
            let vc = DC_Password(didSavePassword: { [weak self] in
                self?.completion?()
            })
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
