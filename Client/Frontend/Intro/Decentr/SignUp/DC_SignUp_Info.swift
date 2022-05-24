// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import AloeStackView
import SnapKit
import UIKit

final class DC_SignUp_Info: UIViewController {
    
    private let completion: (SignUpData) -> ()
    private var info: SignUpData
    private let isEditingMode: Bool
    
    init(info: SignUpData, isEditingMode: Bool, completion: @escaping (SignUpData) -> ()) {
        self.info = info
        self.completion = completion
        self.isEditingMode = isEditingMode
        super.init(nibName: nil, bundle: nil)
        
        title = "User settings"
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private var nextButtonBottomConstraint: Constraint? = nil
    private lazy var nextButton: UIButton = DC_UI.makeActionButton(text: "Save", action: { [weak self] in
        if var info = self?.info {
            info.avatarIndex = self?.picSelector.selectedIndex
            self?.completion(info)
            if self?.isEditingMode == true {
                self?.navigationController?.popViewController(animated: false)
            }
        }
    })
    private lazy var aloeStackView: AloeStackView = DC_UI.makeAloe()
    
    private lazy var picSelector: ProfilePicSelector = {
       let view = ProfilePicSelector(selectedIndex: 1)
        return view
    }()
    
    private lazy var firstName: ProtectedTextView = makeInput({ [weak self] value in
        self?.info.firstName = value
    })
    private lazy var lastName: ProtectedTextView = makeInput({ [weak self] value in
        self?.info.lastName = value
    })
    private lazy var bio: ProtectedTextView = makeInput({ [weak self] value in
        self?.info.bio = value
    })
    
    private lazy var email: ProtectedTextView = makeInput({ _ in })
    
    private lazy var datePicker: UIDatePicker = {
       let dp = UIDatePicker()
        dp.datePickerMode = .date
        if #available(iOS 13.4, *) {
            if #available(iOS 14.0, *) {
                dp.preferredDatePickerStyle = .inline
            } else {
                dp.preferredDatePickerStyle = .wheels
            }
        }
        dp.addTarget(self, action: #selector(dateChanged(_ :)), for: .valueChanged)
        return dp
    }()
    
    @objc func dateChanged(_ picker: UIDatePicker) {
        let date = picker.date
        let df = DateFormatter()
        df.timeZone = .current
        df.calendar = .current
        df.dateFormat = "yyyy-MM-dd"
        let dateString = df.string(from: date)
        info.birthday = dateString
        birthDate.text = dateString
    }
    
    private lazy var birthDate: ProtectedTextView = {
        let input = makeInput({ [weak self] value in
        })
        input.inputView = datePicker
        return input
    }()

    private lazy var gender: UIButton = {
        let gender: UIButton = .init(type: .custom)
        gender.setTitleColor(.black, for: .normal)
        gender.contentHorizontalAlignment = .left
        gender.setAction { [weak self] in
            self?.showGenderPicker({ value in
                if value != "Unspecified" {
                    self?.info.gender = value
                }
                self?.gender.setTitle(value, for: .normal)
            })
        }
        return gender
    }()
    
    private func makeInput(_ onChange: @escaping (String?) -> ()) -> ProtectedTextView {
        let field = ProtectedTextView(textColor: DC_UI.primaryColor, onChangeText: { [weak self] text in
            self?.nextButton.isEnabled = self?.isValidInput() ?? false
            onChange(text)
        })
        field.limit = 20
        field.keyboardType = .emailAddress
        field.isProtected = false
        return field
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHideKeyboardWhenTappedAroundBehaviour()
        
        DC_UI.styleVC(self)
        if !isEditingMode {
            DC_UI.hideBackButton(from: self)
        }
        
        view.addSubview(aloeStackView)
        aloeStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
        }
        
        let title = DC_UI.makeTitleLabel("Your profile picture")
        aloeStackView.addRow(title)
        aloeStackView.setInset(forRow: title, inset: .init(top: 10, left: 0, bottom: 0, right: 0))

        let subtitle = DC_UI.makeDescriptionLabel("It will appear on your posts and comments across Decentr.")
        aloeStackView.addRow(subtitle)
        aloeStackView.setInset(forRow: subtitle, inset: .init(top: 10, left: 0, bottom: 10, right: 0))

        aloeStackView.addRow(picSelector)
        picSelector.selectedIndex = info.avatarIndex ?? 1
        picSelector.snp.makeConstraints { make in
            make.height.equalTo(40)
        }

        let title2 = DC_UI.makeTitleLabel("Personal info")
        aloeStackView.addRow(title2)
        aloeStackView.setInset(forRow: title2, inset: .init(top: 15, left: 0, bottom: 0, right: 0))
        
        let subtitle2 = DC_UI.makeDescriptionLabel("Something that will allow others to identifying you better than a simple image.")
        aloeStackView.addRow(subtitle2)
        aloeStackView.setInset(forRow: subtitle2, inset: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        let fn = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("First name *"), textView: firstName)
        firstName.limit = 20
        aloeStackView.addRow(fn)
        
        let ln = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("Last name"), textView: lastName)
        lastName.limit = 20
        aloeStackView.addRow(ln)
        
        let bio = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("Your bio"), textView: self.bio, height: 120)
        self.bio.limit = 70
        aloeStackView.addRow(bio)
        
        let gen = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("Gender"), textView: gender)
        aloeStackView.addRow(gen)
        
        let birth = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("Your birth date"), textView: birthDate)
        aloeStackView.addRow(birth)
        if let dateString = info.birthday {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            if let date = df.date(from: dateString) {
                datePicker.date = date
                birthDate.text = dateString
            }
        }
        
        if isEditingMode {
            
        } else {
            let emailTitle = DC_UI.makeTitleLabel("Connected email")
            aloeStackView.addRow(emailTitle)
            aloeStackView.setInset(forRow: emailTitle, inset: .init(top: 30, left: 0, bottom: 10, right: 0))
            
            let email = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("Email"), textView: self.email)
            email.isUserInteractionEnabled = false
            aloeStackView.addRow(email)
        }
        
//        let title4 = DC_UI.makeTitleLabel("Set new password")
//        aloeStackView.addRow(title4)
//        aloeStackView.setInset(forRow: title4, inset: .init(top: 15, left: 0, bottom: 0, right: 0))
//
//        let subtitle4 = DC_UI.makeDescriptionLabel("At least 8 symbols with 1 capital letter and 1 special symbol that you’ll use to log in to your account or lock/unlock it.")
//        aloeStackView.addRow(subtitle4)
//        aloeStackView.setInset(forRow: subtitle4, inset: .init(top: 10, left: 0, bottom: 0, right: 0))
//
//        let cp = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("Old password"), textView: currentPassword)
//        aloeStackView.addRow(cp)
//
//        let np = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("New password"), textView: newPassword)
//        aloeStackView.addRow(np)
//
//        let npr = DC_UI.makeTextInputComponent(fieldLabel: DC_UI.makeFieldLabel("New password confirmation"), textView: newRepeatPassword)
//        aloeStackView.addRow(npr)
        
        aloeStackView.setInset(forRows: [fn, ln, bio, birth, gen], inset: .init(top: 7, left: 0, bottom: 0, right: 0))
        
        if let fn = info.firstName {
            firstName.plainText = fn
            firstName.text = fn
        }
        if let ln = info.lastName {
            lastName.plainText = ln
            lastName.text = ln
        }
        if let bi = info.bio {
            self.bio.plainText = bi
            self.bio.text = bi
        }
        if let gen = info.gender?.capitalizedFirst {
            gender.setTitle(gen, for: .normal)
        } else {
            gender.setTitle("Unspecified", for: .normal)
        }
        
        
        if let em = info.email {
            self.email.plainText = em.capitalizedFirst
            self.email.text = em.capitalizedFirst
        }
        
        nextButton.isEnabled = isValidInput()
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(DC_UI.buttonEdgeInset)
            make.height.equalTo(DC_UI.buttonHeight)
            self.nextButtonBottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-30).constraint
        }
        
        addKeyboardChangeFrameObserver(willShow: { [weak self] height in
            guard let self = self else { return }
            let btnY = self.view.frame.height - self.nextButton.frame.origin.y - CGFloat(DC_UI.buttonHeight) - 40
            let h = height - btnY
            self.nextButtonBottomConstraint?.update(offset: -h)
            self.aloeStackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100 + h, right: 0)
            self.view.layoutIfNeeded()
        }, willHide: { [weak self] height in
            self?.nextButtonBottomConstraint?.update(offset: -30)
            self?.aloeStackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
            self?.view.layoutIfNeeded()
        })
    }
    
    private func isValidInput() -> Bool {
        return firstName.plainText.count > 0
    }
    
    private func showGenderPicker(_ completion: @escaping (String) -> ()) {
        let alert = UIAlertController(title: "Gender", message: "Select your gender", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Male", style: .default, handler: { action in
            completion(action.title ?? "")
        }))
        alert.addAction(UIAlertAction(title: "Female", style: .default, handler: { action in
            completion(action.title ?? "")
        }))
        alert.addAction(UIAlertAction(title: "Unspecified", style: .default, handler: { action in
            completion(action.title ?? "")
        }))
        present(alert, animated: true)
    }
}

final class ProfilePicSelector: UIView {
    
    var selectedIndex: Int {
        didSet {
            buttons.forEach({ $0.isSelected = false })
            if let idx = buttons.firstIndex(where: { $0.tag ==  selectedIndex }) {
                buttons[idx].isSelected = true
            }
        }
    }
    private var buttons: [UIButton] = []
    
    init(selectedIndex: Int) {
        self.selectedIndex = selectedIndex
        
        super.init(frame: .zero)
        
        addSubview(aloeStackView)
        aloeStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.buttons = Array(1 ... 12).map({ index in
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "user-avatar-\(index)"), for: .normal)
            button.setImage(UIImage(), for: .normal)
            button.setImage(UIImage(named: "avatar-checkmark"), for: .selected)
            button.contentVerticalAlignment = .bottom
            button.contentHorizontalAlignment = .right
            button.setAction { [weak self, weak button] in
                self?.buttons.forEach({ $0.isSelected = false })
                button?.isSelected = true
                self?.selectedIndex = button?.tag ?? 0
            }
            button.isSelected = index == selectedIndex
            button.tag = index
            button.snp.makeConstraints { make in
                make.width.height.equalTo(40)
            }
            return button
        })
        
        self.buttons.forEach { button in
            self.aloeStackView.addRow(button)
            if button.tag > 1 {
                self.aloeStackView.setInset(forRow: button, inset: .init(top: 0, left: 5, bottom: 0, right: 0))
            }
        }
    }
    
    
    
    private lazy var aloeStackView: AloeStackView = DC_UI.makeAloe(axis: .horizontal, contentInset: .zero)
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
