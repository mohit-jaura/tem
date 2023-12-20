//
//  AWSCredentials.swift
//  TemApp
//
//  Created by shilpa on 09/12/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

struct AWSCredentials: Codable {
    var url: String?
    var bucketName: String?
    var amz_algorithm: String?
    var amz_credential: String?
    var policy: String?
    var amz_signature: String?
    var prefix: String?
    var acl: String?
    var successActionStatus: String?
    var amz_date: String?
    
    enum CodingKeys: String, CodingKey {
        case bucketName = "bucket"
        case amz_algorithm = "X-Amz-Algorithm"
        case amz_credential = "X-Amz-Credential"
        case policy = "Policy"
        case amz_signature = "X-Amz-Signature"
        //case prefix = "tem_file_prefix"
        case acl = "acl"
        case successActionStatus = "success_action_status"
        case amz_date = "X-Amz-Date"
    }
    
    //custom initializer
    init(data: [String: Any]) {
        if let url = data["url"] as? String {
            self.url = url
        }
        if let fields = data["fields"] as? Parameters {
            self.bucketName = fields[CodingKeys.bucketName.rawValue] as? String
            self.amz_algorithm = fields[CodingKeys.amz_algorithm.rawValue] as? String
            self.amz_credential = fields[CodingKeys.amz_credential.rawValue] as? String
            self.amz_signature = fields[CodingKeys.amz_signature.rawValue] as? String
            self.policy = fields[CodingKeys.policy.rawValue] as? String
            self.amz_date = fields[CodingKeys.amz_date.rawValue] as? String
        }
        self.prefix = data["tem_file_prefix"] as? String
        self.acl = data[CodingKeys.acl.rawValue] as? String
        self.successActionStatus = data[CodingKeys.successActionStatus.rawValue] as? String
    }
    
}
