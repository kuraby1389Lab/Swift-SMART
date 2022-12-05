//
//  SMARTAuthParameters.swift
//  SwiftSMART
//
//  Created by Trystan on 5/12/2022.
//  Copyright © 2022 SMART Health IT. All rights reserved.
//

import Foundation


public struct SMARTAuthParameters: Equatable {
    public init(clientID: String,
                clientSecret: String? = nil,
                scopes: [String]? = nil,
                redirectURL: URL? = nil,
                responseType: String,
                state: String? = nil,
                nonce: String? = nil,
                codeVerifier: String? = nil,
                codeChallenge: String? = nil,
                codeChallengeMethod: String? = nil,
                additionalParameters: [String : String]? = nil) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.scopes = scopes
        self.redirectURL = redirectURL
        self.responseType = responseType
        self.state = state
        self.nonce = nonce
        self.codeVerifier = codeVerifier
        self.codeChallenge = codeChallenge
        self.codeChallengeMethod = codeChallengeMethod
        self.additionalParameters = additionalParameters
    }
    
    public var clientID: String
    public var clientSecret: String?
    public var scopes:[String]?
    public var redirectURL: URL?
    public var responseType: String
    public var state: String?
    public var nonce: String?
    public var codeVerifier: String?
    public var codeChallenge: String?
    public var codeChallengeMethod: String?
    public var additionalParameters: [String: String]?
}
