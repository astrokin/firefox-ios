// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import SnapKit
import AloeStackView
import DecentrAPI

final class DC_Account_Info: UIViewController {
    
    private let account: DecentrAccount
    
    init(account: DecentrAccount) {
        self.account = account
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Profile"
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private lazy var aloeStackView: AloeStackView = DC_UI.makeAloe()
    
    private lazy var copyButton: UIButton = DC_UI.makeSmallButton(image: "decentr-copy", title: "Copy wallet address", action: { [weak self] in
        if let addr = self?.account.baseAccount?.account?.address {
            UIPasteboard.general.string = addr
            self?.showMessage("Copied")
        }
    })
    
    private lazy var nextButton: UIButton = DC_UI.makeActionButton(text: "Return to Decentr Browser", action: { [weak self] in
        if self?.navigationController?.popToRootViewController(animated: true) == nil {
            self?.dismiss(animated: true, completion: nil)
        }
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHideKeyboardWhenTappedAroundBehaviour()
        
        DC_UI.styleVC(self)
        
        let inset: CGFloat = CGFloat(DC_UI.buttonEdgeInset / (UIDevice.isSmall ? 2 : 1))
        
        view.addSubview(aloeStackView)
        aloeStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview().inset(inset)
        }
        
        let balancePlaceholder: UIView = .init()
        balancePlaceholder.backgroundColor = UIColor.hexColor("F6F6F7")
        balancePlaceholder.layer.cornerRadius = 12
        balancePlaceholder.clipsToBounds = true
        let balanceTitle = DC_UI.makeFieldLabel("Your balance")
        
        let dec = account.decBalance?.balance?.dec ?? ""
        let pdv = account.pdvBalance?.balances?.first?.amount ?? ""
        let nom = account.pdvBalance?.balances?.first?.denom ?? ""
        let balanceValueLabel = DC_UI.makeTitleSmallLabel("\(dec.prefix(8)) DEC | \(pdv.prefix(7)) \(nom)")
        
        balancePlaceholder.addSubview(balanceTitle)
        balanceTitle.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview().inset(inset)
            make.height.equalTo(24)
        }
        balancePlaceholder.addSubview(balanceValueLabel)
        balanceValueLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(inset)
            make.top.equalTo(balanceTitle.snp.bottom)
            make.height.equalTo(24)
        }
        
        let pending = DC_PDV_Monitor.shared.getPendingPDV()
        let pendingLabel = DC_UI.makeInfoSmallLabel("Pending: \(pending) PDV")
        balancePlaceholder.addSubview(pendingLabel)
        pendingLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(inset)
            make.top.equalTo(balanceValueLabel.snp.bottom)
            make.height.equalTo(16)
        }
        
        balancePlaceholder.addSubview(copyButton)
        copyButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(inset)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-10)
        }
        balancePlaceholder.snp.makeConstraints { make in
            make.height.equalTo(145)
        }
        
        let edit = DC_UI.makeSecondaryActionButton(text: "Edit account information", image: UIImage(named: "dc-edit-account")) { [weak self] in
            let data = SignUpData(account: DC_Shared_Info.shared.getAccount())
            let vc =  DC_SignUp_Info(info: data, isEditingMode: true) { info in
                self?.performUpdateProfile(info)
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        let settings = DC_UI.makeSecondaryActionButton(text: "Settings", image: UIImage(named: "dc-profile-settings")) { [weak self] in

        }
        
        let logout = DC_UI.makeSecondaryActionButton(text: "Log out", image: UIImage(named: "dc-logout-account")) { [weak self] in
            self?.performLogoutAction()
        }
        
        aloeStackView.addRow(balancePlaceholder)
        aloeStackView.setInset(forRow: balancePlaceholder, inset: .init(top: 20, left: CGFloat(inset), bottom: 10, right: CGFloat(inset)))
        
        aloeStackView.addRow(edit)
        aloeStackView.setInset(forRow: edit, inset: .init(top: 10, left: CGFloat(inset), bottom: 0, right: CGFloat(inset)))
        edit.snp.makeConstraints { make in
            make.height.equalTo(DC_UI.buttonHeight)
        }
        
//        aloeStackView.addRow(settings)
//        aloeStackView.setInset(forRow: settings, inset: .init(top: 10, left: CGFloat(inset), bottom: 0, right: CGFloat(inset)))
//        settings.snp.makeConstraints { make in
//            make.height.equalTo(DC_UI.buttonHeight)
//        }
        
        aloeStackView.addRow(logout)
        aloeStackView.setInset(forRow: logout, inset: .init(top: 10, left: CGFloat(inset), bottom: 0, right: CGFloat(inset)))
        logout.snp.makeConstraints { make in
            make.height.equalTo(DC_UI.buttonHeight)
        }
        
        nextButton.isEnabled = true
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(inset)
            make.height.equalTo(DC_UI.buttonHeight)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
    }
    
    private func showMessage(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
            self.navigationController?.present(alert, animated: true)
        }
    }
    
    private func performLogoutAction() {
        let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out of your Decentr account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { [weak self] _ in
            DC_Shared_Info.shared.purge()
            if self?.navigationController?.popToRootViewController(animated: true) == nil {
                self?.dismiss(animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak self] _ in
            
        }))
        present(alert, animated: true)
    }
    
    private func performUpdateProfile(_ info: SignUpData) {
        
        guard let body = PDVPrifileRequest(data: info) else {
            showMessage("Error")
            return
        }
        UIApplication.getKeyWindow()?.showLoader()
        let reqBuilder = CerberusAPI.PDVAPI.saveProfileWithRequestBuilder(body: body)
        reqBuilder.executeSignRequest { [weak self] response in
            DC_Shared_Info.shared.refreshAccountInfo(address: nil) { result in
                UIApplication.getKeyWindow()?.removeLoader()
                
                switch result {
                case .failure:
                    self?.showMessage("Error")
                case .success:
                    self?.showMessage("Updated")
                }
            }
        } failed: { [weak self] error in
            self?.showMessage("Error: \(error?.localizedDescription ?? "")")
            UIApplication.getKeyWindow()?.removeLoader()
        }
    }
}
