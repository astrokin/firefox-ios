// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import SnapKit
import UIKit
import HDWalletKit
import AloeStackView

final class DC_SignUp_Seed: UIViewController {
    
    var seedPhrase: String?
    private let completion: (String?) -> ()
    
    init(completion: @escaping (String?) -> ()) {
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Create a new account"
    }
    
    deinit {
        if let token = keyboardChangeFrameObserverToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private lazy var titleLabel: UILabel = DC_UI.makeTitleLabel("Store your seed phrase")
    private lazy var descriptionLabel: UILabel = DC_UI.makeDescriptionLabel("It is the only way to import or restore your account, so copy, download, print and store it somewhere safely!")
    private lazy var seedLabel: UILabel = DC_UI.makeFieldLabel("Your seed phrase")
    private lazy var copyButton: UIButton = DC_UI.makeSmallButton(image: "decentr-copy", title: "Copy", action: { [weak self] in
        if let seed = self?.seedPhrase {
            UIPasteboard.general.string = seed
        }
    })
    private lazy var downloadButton: UIButton = DC_UI.makeSmallButton(image: "decentr-download", title: "Download txt", action: {
        
    })
    private lazy var printButton: UIButton = DC_UI.makeSmallButton(image: "decentr-print", title: "Print", action: {
        
    })
    private lazy var eyeButton: UIButton = DC_UI.makeEyeButton(action: { [weak self] in
        guard let self = self else { return }
        
        self.eyeButton.isSelected = !self.eyeButton.isSelected
        self.textView.isProtected = !self.eyeButton.isSelected
    })
    
    private lazy var textView: ProtectedTextView = {
        let textView = ProtectedTextView(textColor: DC_UI.primaryColor, onChangeText: { [weak self] text in
            self?.nextButton.isEnabled = text.count > 0
            self?.eyeButton.isEnabled = text.count > 0
        })
        textView.isEditable = false
        if let text = seedPhrase, text.count > 0 {
            textView.plainText = text
            textView.isProtected = true
            nextButton.isEnabled = true
        }
        return textView
    }()
    
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
    
    private var nextButtonBottomConstraint: Constraint? = nil
    
    private lazy var nextButton: UIButton = DC_UI.makeActionButton(text: "Next", action: { [weak self] in
        self?.completion(self?.seedPhrase)
    })
    
    private lazy var noticeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hexColor("FA545414")
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        
        let noteIcon = UIImageView(image: UIImage(named: "decentr-loud"))
        view.addSubview(noteIcon)
        noteIcon.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(12)
            make.height.width.equalTo(24)
        }
        
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.hexColor("FA5454")
        titleLabel.text = "Store safe and never share your seed phrase"
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(40)
            make.top.right.equalToSuperview().inset(12)
            make.height.equalTo(24)
        }
        
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = DC_UI.primaryColor
        descriptionLabel.text = """
        Anyone with this phrase can take your Decs forever.
        We won’t be able to recover it or return your account and wallet to you.
        If you’ll lose the seed phrase you’ll lose your account forever.
        It’s the only place you can see and save your seed phrase.
        You won’t be able to do it later.
        """
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(40)
            make.bottom.right.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        return view
    }()
    
    private lazy var tipsLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        var attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.hexColor("929297"),
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(string: "Tips on storing seed phrase:", attributes: attributes))
        attributes[.font] = UIFont.systemFont(ofSize: 12, weight: .regular)
        text.append(NSAttributedString(string: "\n* Save backup in multiple places and never share the phrase with anyone.", attributes: attributes))
        text.append(NSAttributedString(string: "\n* Be careful of fishing! Decentr will never spontaneously ask for your seed phrase.", attributes: attributes))
        text.append(NSAttributedString(string: "\n* Decentr can not recover your seed phrase!", attributes: attributes))
        label.attributedText = text
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DC_UI.styleVC(self)
        
        view.addSubview(aloeStackView)
        aloeStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
        }

        aloeStackView.addRow(titleLabel)
        aloeStackView.setInset(forRow: titleLabel, inset: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        aloeStackView.addRow(descriptionLabel)
        aloeStackView.setInset(forRow: descriptionLabel, inset: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        let textPlaceholder: UIView = DC_UI.makeTextInputComponent(fieldLabel: seedLabel,
                                                                      eyeButton: eyeButton,
                                                                      textView: textView)
        textPlaceholder.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        aloeStackView.addRow(textPlaceholder)
        aloeStackView.setInset(forRow: textPlaceholder, inset: .init(top: 15, left: 0, bottom: 0, right: 0))
        
        textPlaceholder.addSubview(copyButton)
        copyButton.snp.makeConstraints { make in
            make.bottom.left.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        textPlaceholder.addSubview(downloadButton)
        downloadButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.left.equalTo(self.copyButton.snp.right).offset(12)
            make.height.equalTo(48)
        }
        
        textPlaceholder.addSubview(printButton)
        printButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.left.equalTo(self.downloadButton.snp.right).offset(12)
            make.height.equalTo(48)
        }
        
        aloeStackView.addRow(noticeView)
        aloeStackView.setInset(forRow: noticeView, inset: .init(top: 15, left: 0, bottom: 0, right: 0))
        
        aloeStackView.addRow(tipsLabel)
        aloeStackView.setInset(forRow: tipsLabel, inset: .init(top: 5, left: 0, bottom: 0, right: 0))
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
            make.height.equalTo(DC_UI.buttonHeight)
            self.nextButtonBottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-30).constraint
        }
        
        DC_UI.embedBackButton(on: self)
        
        addKeyboardChangeFrameObserver(willShow: { [weak self] height in
            guard let self = self else { return }
            let btnY = self.view.frame.height - self.nextButton.frame.origin.y - CGFloat(DC_UI.buttonHeight) - 40
            let h = height - btnY
            self.nextButtonBottomConstraint?.update(offset: -h)
            self.view.layoutIfNeeded()
        }, willHide: { [weak self] height in
            self?.nextButtonBottomConstraint?.update(offset: -30)
            self?.view.layoutIfNeeded()
        })
        
        DispatchQueue.main.async {
            self.generateSeed()
        }
    }
    
    private func generateSeed() {
        let words = Mnemonic.create(strength: .hight, language: .english)
        self.seedPhrase = words
        self.textView.plainText = words
        self.textView.isProtected = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        [copyButton, downloadButton, printButton].forEach({ $0.invalidateIntrinsicContentSize() })
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
