// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import SnapKit

final class DC_Login: UIViewController {
    
    var completion: (() -> ())?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        title = "Sign in as existing user"
    }
    
    private(set) lazy var qrCodeScanner: QRCodeViewController = {
        let vc = QRCodeViewController()
        vc.instructionsLabel.isHidden = true
        return vc
    }()
    
    private lazy var enterSeedPhraseButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "enterSeedPhraseButton"
        button.layer.cornerRadius = 12
        button.backgroundColor = .white
        button.setTitle("Enter seed phrase", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(UIColor.Decentr.BlackText, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setAction { [weak self] in
            self?.completion?()
        }
        return button
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "To find QR code go to user settings in Decentr or enter seed phrase manually."
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DC_UI.styleVC(self, color: .white)
        
        addChild(qrCodeScanner)
        view.addSubview(qrCodeScanner.view)
        qrCodeScanner.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        qrCodeScanner.didMove(toParent: self)
        
        let buttonEdgeInset = 15
        let buttonHeight = 46
        
        view.addSubview(enterSeedPhraseButton)
        enterSeedPhraseButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(buttonEdgeInset)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(30)
            make.height.equalTo(buttonHeight)
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(buttonEdgeInset)
            make.bottom.equalTo(self.enterSeedPhraseButton.snp.top).inset(-20)
        }
        
        DC_UI.embedBackButton(on: self, color: .white)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}
