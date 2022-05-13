// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import SnapKit
import AloeStackView

final class DC_SignUp_Settings: UIViewController {
    
    private let completion: (SignUpData) -> ()
    private var info: SignUpData
    
    init(info: SignUpData, completion: @escaping (SignUpData) -> ()) {
        self.info = info
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Tracking settings"
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private var nextButtonBottomConstraint: Constraint? = nil
    private lazy var nextButton: UIButton = DC_UI.makeActionButton(text: "Save", action: { [weak self] in
        if var info = self?.info {
            self?.completion(info)
        }
    })
    
    private lazy var aloeStackView: AloeStackView = DC_UI.makeAloe()
    
    private(set) lazy var userInfoBg: UIView = {
        let userInfoBg = UIView()
        userInfoBg.backgroundColor = UIColor.hexColor("F6F6F7")
        userInfoBg.layer.cornerRadius = 12
        userInfoBg.clipsToBounds = true
        
        let userPic = UIImageView(image: UIImage(named: "user-avatar-\(info.avatarIndex ?? 1)"))
        userInfoBg.addSubview(userPic)
        userPic.snp.makeConstraints { make in
            make.width.height.equalTo(54)
            make.left.top.equalToSuperview().inset(15)
        }
        
        let name = info.firstName ?? "" + (info.lastName ?? "")
        let fio = DC_UI.makeTitleLabel(name)
        userInfoBg.addSubview(fio)
        fio.snp.makeConstraints { make in
            make.centerY.equalTo(userPic.snp.centerY)
            make.left.equalTo(userPic.snp.right).inset(10)
            make.right.equalToSuperview().inset(10)
        }
        
        let infoLabel = DC_UI.makeFieldLabel(info.bio ?? "")
        userInfoBg.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.left.equalTo(fio.snp.left)
            make.top.equalTo(fio.snp.bottom).inset(3)
            make.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }
        
        return userInfoBg
    }()
    
    private lazy var pdvInfo: UIView = {
        let pdvInfoRow = UIView()
        pdvInfoRow.backgroundColor = UIColor.hexColor("4F80FF").withAlphaComponent(0.12)
        pdvInfoRow.layer.cornerRadius = 12
        pdvInfoRow.clipsToBounds = true
        
        let icon = UIImageView(image: UIImage(named: "PDV tracking insights"))
        pdvInfoRow.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.left.top.equalToSuperview().inset(10)
        }

        let label = DC_UI.makeDescriptionLabel("Selected options will directly affect the PDV, the less we track the less will be your PDV.")
        
        return pdvInfoRow
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DC_UI.styleVC(self)
        DC_UI.embedNavBackButton(on: self)
        
        view.addSubview(aloeStackView)
        aloeStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
        }
        
        let titleLabel = DC_UI.makeTitleLabel("Check information we can track and transfer into PDV")
        titleLabel.numberOfLines = 2
        aloeStackView.addRow(titleLabel)
        aloeStackView.setInset(forRow: titleLabel, inset: .init(top: 25, left: 0, bottom: 10, right: 0))
        
        
        let description = DC_UI.makeDescriptionLabel("We’ll use information about the sites you visit in order to transform it into a PDV rate. PDV rate affects lots of aspects of your life in Decentr. We recommend to check them all.")
        aloeStackView.addRow(description)
        aloeStackView.setInset(forRow: description, inset: .init(top: 5, left: 0, bottom: 10, right: 0))
        
        let advertiser = makeSwitchRow(icon: "Advertiser id", title: "Advertiser Id", action: { value in
            
        })
        
        let cookies = makeSwitchRow(icon: "Cookies", title: "Cookie", action: { value in
            
        })
        
        let history = makeSwitchRow(icon: "Search history", title: "Search History", action: { value in
            
        })
        
        let location = makeSwitchRow(icon: "Location", title: "Location", action: { value in
            
        })
        let switchRows = [advertiser, cookies, history, location]
        aloeStackView.addRows(switchRows)
        aloeStackView.setInset(forRows: switchRows, inset: .init(top: 5, left: 0, bottom: 5, right: 0))
        
        
    }
    
    private func makeSwitchRow(icon: String, title: String, action: @escaping ((Bool) -> ()) ) -> UIView {
        let row = UIView()
        let switcher = UISwitch()
        switcher.isOn = true
        switcher.setAction { [unowned switcher] in
            switcher.isOn = !switcher.isOn
            action(switcher.isOn)
        }
        row.addSubview(switcher)
        switcher.snp.makeConstraints { make in
            make.width.equalTo(51)
            make.height.equalTo(31)
            make.top.left.bottom.equalToSuperview().inset(10)
        }
        
        let icon = UIImageView(image: UIImage(named: icon)?.blendedByColor(UIColor.hexColor("929297")))
        row.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.centerY.equalToSuperview()
            make.left.equalTo(switcher.snp.right).inset(10)
        }
        
        let titleLabel = DC_UI.makeDescriptionLabel(title)
        row.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.left.equalTo(icon.snp.right).inset(10)
        }
        
        return row
    }
}
