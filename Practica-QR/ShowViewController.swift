//
//  ShowViewController.swift
//  Practica-QR
//
//  Created by Agustinch on 15/12/2022.
//

import UIKit

class ShowViewController: UIViewController {
    
    lazy private var labelScaner: UILabel = {
        let label = UILabel()
        label.text = "BarCode"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var openQRScaner: UIButton = {
        let button = UIButton()
        button.setTitle("Open Scaner", for: .normal)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .orange
        button.addTarget(self, action: #selector(showControllerQR), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(openQRScaner)
        view.addSubview(labelScaner)
        view.backgroundColor = .white
        setupConstrainst()
    }

    @objc private func showControllerQR() {
        let viewController = ScannerViewController()
        viewController.modalPresentationStyle = .fullScreen
        viewController.delegate = self
        
        guard let navigationController  = navigationController else {
            print("algo pasa")
            return }
        
        navigationController.pushViewController(viewController, animated: true)
    }

    private func setupConstrainst() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            labelScaner.bottomAnchor.constraint(equalTo: openQRScaner.bottomAnchor, constant: -100),
            
            labelScaner.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            openQRScaner.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            openQRScaner.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            openQRScaner.widthAnchor.constraint(equalToConstant: 200),
            openQRScaner.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
}

extension ShowViewController: ScannerDelegate {
    func receivingBarcode(code: String) {
        labelScaner.text = code
    }
}
