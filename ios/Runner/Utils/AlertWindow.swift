//
//  AlertWindow.swift
//  Runner
//
//  Created by Yerzhan Tulepov on 20.01.2022.
//

func showAlert(message: String) {
    let v = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
    v.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    UIApplication.shared.keyWindow?.rootViewController?.present(v, animated: true, completion: nil)
}
