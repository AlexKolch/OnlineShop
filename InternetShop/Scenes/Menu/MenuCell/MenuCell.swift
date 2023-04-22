//
//  MenuTableViewCell.swift
//  InternetShop
//
//  Created by Алексей Колыченков on 19.04.2023.
//

import UIKit

protocol CellModelRepresentable {
    var viewModel: MenuCellViewModelProtocol? {get}
}

class MenuCell: UITableViewCell, CellModelRepresentable {

    // MARK: - Identifier
    static let identifier = "MenuCell"

    private lazy var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()

    private lazy var cellTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var cellDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 8)
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var cellPriceButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.setTitleColor(UIColor(named: "customRed"), for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "customRed")?.cgColor
        button.layer.cornerRadius = 6
        return button
    }()

    var viewModel: MenuCellViewModelProtocol? {
        didSet {
            backgroundColor = .white
            addSubviews()
            setupConstraints()
            activityIndicator.startAnimating()
            setView()
        }
    }


    private func setView() {
        guard let viewModel = viewModel as? MenuCellViewModel else {return}

        ImageManager.shared.fetchImage(from: viewModel.imageURL) { [weak self] result in
            switch result {
            case .success(let imageData):
                self?.cellImageView.image = UIImage(data: imageData)
                self?.activityIndicator.stopAnimating()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        cellTitleLabel.text = viewModel.name
        cellDescriptionLabel.text = viewModel.description
        cellPriceButton.setTitle("\(viewModel.price)$", for: .normal)
    }

    private func addSubviews() {
        addSubview(cellImageView)
        cellImageView.addSubview(activityIndicator)
        addSubview(cellTitleLabel)
        addSubview(cellDescriptionLabel)
        addSubview(cellPriceButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            cellImageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cellImageView.widthAnchor.constraint(equalToConstant: 100),
            cellImageView.heightAnchor.constraint(equalToConstant: 100),

            activityIndicator.centerXAnchor.constraint(equalTo: cellImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: cellImageView.centerYAnchor),

            cellTitleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            cellTitleLabel.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 16),
            cellTitleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),

            cellDescriptionLabel.topAnchor.constraint(equalTo: cellTitleLabel.bottomAnchor, constant: 6),
            cellDescriptionLabel.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 16),
            cellDescriptionLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),

            cellPriceButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cellPriceButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            cellPriceButton.widthAnchor.constraint(equalToConstant: 70),
        ])
    }
    

}
