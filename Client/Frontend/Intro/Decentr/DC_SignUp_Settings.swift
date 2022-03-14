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
        
        title = "User settings"
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private var nextButtonBottomConstraint: Constraint? = nil
    private lazy var nextButton: UIButton = DC_UI.makeActionButton(text: "Save", action: { [weak self] in
        if var info = self?.info {
            self?.completion(info)
        }
    })
    
    private lazy var aloeStackView: AloeStackView = {
        let aloeStackView = AloeStackView()
        aloeStackView.axis = .vertical
        aloeStackView.isPagingEnabled = false
        aloeStackView.hidesSeparatorsByDefault = true
        aloeStackView.showsVerticalScrollIndicator = false
        aloeStackView.contentInsetAdjustmentBehavior = .never
        aloeStackView.rowInset = .zero
        aloeStackView.backgroundColor = .clear
        aloeStackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        return aloeStackView
    }()
}
