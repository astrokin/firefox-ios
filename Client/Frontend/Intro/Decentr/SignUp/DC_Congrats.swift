// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import SnapKit
import AloeStackView

final class DC_Congrats: UIViewController {
    
    private let completion: () -> ()
    
    init(completion: @escaping () -> ()) {
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private lazy var aloeStackView: AloeStackView = DC_UI.makeAloe()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DC_UI.styleVC(self)
        DC_UI.hideBackButton(from: self)
        
        view.addSubview(aloeStackView)
        aloeStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
        }
        
        let image = UIImageView(image: UIImage(named: "Congratulations"))
        image.contentMode = .scaleAspectFit
        aloeStackView.addRow(image)
        image.snp.makeConstraints { make in
            make.height.width.equalTo(96)
        }
        aloeStackView.setInset(forRow: image, inset: .init(top: 50, left: CGFloat(DC_UI.buttonEdgeInset), bottom: 20, right: CGFloat(DC_UI.buttonEdgeInset)))
        
        let title = DC_UI.makeTitleLabel("Congratulations, you’re all set!")
        title.adjustsFontSizeToFitWidth = true
        aloeStackView.addRow(title)
        aloeStackView.setInset(forRow: title, inset: .init(top: 10, left: CGFloat(DC_UI.buttonEdgeInset), bottom: 0, right: CGFloat(DC_UI.buttonEdgeInset)))
        
        let descriptionLabel = DC_UI.makeDescriptionLabel("Keep your seed phrase safe and remember that it's the only key to all you have on Decentr.")
        descriptionLabel.textAlignment = .center
        aloeStackView.addRow(descriptionLabel)
        aloeStackView.setInset(forRow: descriptionLabel, inset: .init(top: 10, left: CGFloat(DC_UI.buttonEdgeInset), bottom: 0, right: CGFloat(DC_UI.buttonEdgeInset)))
        
        let hint = DC_UI.makeFieldLabel("""
        Save the backup in multiple places and never share the phrase with anyone.
        Be careful of phishing! No one from Decentr will ever ask for your seed phrase!
        If you have questions or see something suspicious, email
        """)
        hint.numberOfLines = 0
        hint.textAlignment = .center
        aloeStackView.addRow(hint)
        aloeStackView.setInset(forRow: hint, inset: .init(top: 10, left: CGFloat(DC_UI.buttonEdgeInset), bottom: 0, right: CGFloat(DC_UI.buttonEdgeInset)))
        
        let email = DC_UI.makeFieldLabel("support@decentr.net")
        email.textAlignment = .center
        email.textColor = UIColor.hexColor("4F80FF")
        aloeStackView.addRow(email)
        aloeStackView.setInset(forRow: email, inset: .init(top: 0, left: CGFloat(DC_UI.buttonEdgeInset), bottom: 0, right: CGFloat(DC_UI.buttonEdgeInset)))
        
        let recover = DC_UI.makeFieldLabel("Decentr can't recover your seed phrase!")
        recover.textAlignment = .center
        aloeStackView.addRow(recover)
        aloeStackView.setInset(forRow: recover, inset: .init(top: 20, left: CGFloat(DC_UI.buttonEdgeInset), bottom: 0, right: CGFloat(DC_UI.buttonEdgeInset)))
        
        let nextButton: UIButton = DC_UI.makeActionButton(text: "Done", action: { [weak self] in
            self?.completion()
        })
        nextButton.isEnabled = true
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
            make.height.equalTo(DC_UI.buttonHeight)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
    }
}
