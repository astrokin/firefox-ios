// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import WebKit
import SnapKit

final class DC_Web: UIViewController {

    private let webView = WKWebView()
    private let titleString: String
    private let url: URL?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        label.textColor = DC_UI.primaryColor
        label.textAlignment = .center
        label.text = titleString
        return label
    }()

    private lazy var backButton: UIButton = DC_UI.makeBackButton(color: DC_UI.primaryColor) { [weak self] in
        if self?.navigationController?.popViewController(animated: true) == nil {
            self?.dismiss(animated: true)
        }
    }

    init(title: String, url: URL?) {
        self.titleString = title
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView.makeGray()
        activity.hidesWhenStopped = true
        return activity
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        webView.alpha = 0
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(70)
        }
        
        view.addSubview(activity)
        activity.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        activity.startAnimating()

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalTo(74)
            make.height.equalTo(70)
        }

        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.left.equalToSuperview().offset(10)
        }
    }
}

extension DC_Web: WKNavigationDelegate {
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        showContent()
    }

    func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        showContent()
    }

    private func showContent() {
        activity.stopAnimating()

        UIView.animate(withDuration: 0.3) {
            self.webView.alpha = 1
        }
    }
}
