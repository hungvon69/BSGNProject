//
//  DoctorHomeTableViewCell.swift
//  BSGNProject
//
//  Created by Hùng Nguyễn on 22/10/24.
//

import UIKit

class DoctorHomeTableViewCell: UITableViewCell, SummaryMethod {

    @IBOutlet private weak var todayLabel: UILabel!
    @IBOutlet private weak var greetingDoctorLabel: UILabel!
    @IBOutlet private weak var doctorAvatarImageView: UIImageView!
    
    var parentViewController: UIViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    private func setupUI() {
        doctorAvatarImageView.layer.cornerRadius = doctorAvatarImageView.frame.height / 1.2
        doctorAvatarImageView.layer.borderColor = UIColor.black.cgColor
        doctorAvatarImageView.layer.borderWidth = 1
        doctorAvatarImageView.image = UIImage(named: "default_doctor")
        avatarTapped()
    }
    func avatarTapped() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (imageViewTapped))
        doctorAvatarImageView.isUserInteractionEnabled = true
        doctorAvatarImageView.addGestureRecognizer(tapGesture)
    }
    @objc func imageViewTapped() {
        guard let viewController = parentViewController else {
            print("Parent view controller is not set.")
            return
        }
        
        // Khởi tạo ImagePickerHelper và gọi pickImage
        ImagePickerHelper.pickImage(for: doctorAvatarImageView, in: viewController)
    }
    func configureCell(avatarURL: String, name: String) {
        greetingDoctorLabel.text = name
        loadAvatarImage(from: avatarURL)
    }
    
    private func loadAvatarImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }
        URLSession.shared.dataTask(with: imageURL) { data, _, error in
            if let error = error {
                print("Failed to load image: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.doctorAvatarImageView.image = image
            }
        }.resume()
    }
    
}
