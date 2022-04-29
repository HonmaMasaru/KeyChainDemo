//
//  ViewController.swift
//  KeyChainDemo
//
//  Created by 本間 on 2021/11/11.
//

import UIKit
import LocalAuthentication
import KeychainAccess
import Toast

final class ViewController: UIViewController {
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var pwField: UITextField!

    private let keychain = Keychain(service: "dev.signpost.KeyChainDemo")

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onTapSaveButton(_ sender: UIButton) {
        var flag = 0
        if let id = idField.text, !id.isEmpty { keychain["id"] = id; flag += 1 }
        if let pw = pwField.text, !pw.isEmpty { keychain["pw"] = pw; flag += 1 }
        showToast(flag > 1 ? "Saved!" : "Unsaved...")
    }

    @IBAction func onTapLoadButton(_ sender: UIButton) {
        loadAccount()
    }

    private func loadAccount() {
        let context = LAContext()
        let reason = "ID / Passを呼び出すのに生体認証を利用します。"
        var authError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    DispatchQueue.main.async {
                        if let id = self.keychain["id"] { self.idField.text = id }
                        if let pw = self.keychain["pw"] { self.pwField.text = pw }
                    }
                    self.showToast("loaded!")
                } else {
                    self.showToast(error?.localizedDescription ?? "Failed to authenticate")
                }
            }
        } else {
            showToast(authError?.localizedDescription ?? "canEvaluatePolicy returned false")
        }
    }

    private func showToast(_ message: String?) {
        DispatchQueue.main.async {
            self.view.makeToast(message, position: .center)
        }
    }
}
