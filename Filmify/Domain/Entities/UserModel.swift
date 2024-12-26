//
//  UserModel.swift
//  Filmify
//
//  Created by Rafael Loggiodice on 15/12/24.
//

import Foundation
import FirebaseCore

struct UserModel: Codable, Identifiable, Sendable {
    let id: String
    let email: String
    let password: String
    let fullName: String
    var createdAt = Timestamp()
        
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let personComponent = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: personComponent)
        }
        return ""
    }
    
    enum CodingKeys: CodingKey {
        case id
        case email, password, fullName, createdAt
    }
}

extension UserModel {
    func toDTO() -> UserModelDTO {
        UserModelDTO(
            id: id,
            email: email,
            fullName: fullName,
            createdAt: createdAt)
    }
}
