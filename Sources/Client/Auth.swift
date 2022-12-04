//
//  Auth.swift
//  SMART-on-FHIR
//
//  Created by Pascal Pfiffner on 6/11/14.
//  Copyright (c) 2014 SMART Health IT. All rights reserved.
//

import Foundation
import AppAuth

public extension URLRequest {
    
    mutating func addAuthorization(accessToken: String) {
        var fields:[String: String] = allHTTPHeaderFields ?? [:]
        fields["Authorization"] = "Bearer \(accessToken)"
        allHTTPHeaderFields = fields
    }
    
}

public struct AuthorizationParameters: Equatable {
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
    
    public func buildRequest(with configuration:OIDServiceConfiguration) -> OIDAuthorizationRequest {
        return OIDAuthorizationRequest(configuration: configuration,
                                       clientId: clientID,
                                       clientSecret: clientSecret,
                                       scope: scopes?.joined(separator: " "),
                                       redirectURL: redirectURL,
                                       responseType: responseType,
                                       state: state,
                                       nonce: nonce,
                                       codeVerifier: codeVerifier,
                                       codeChallenge: codeChallenge,
                                       codeChallengeMethod: codeChallengeMethod,
                                       additionalParameters: additionalParameters)
    }
}

class Auth {
	
    private(set) var state: OIDAuthState?
    private(set) var configuration: OIDServiceConfiguration?
    
    private(set) var session: OIDExternalUserAgentSession?
    
    private(set) var service: OIDAuthorizationService?
    
    let issuer: URL?
	
	/// The server this instance belongs to.
	unowned let server: Server
	
	/// Context used during authorization to pass OS-specific information, handled in the extensions.
	var authContext: AnyObject?
	
	/// The closure to call when authorization finishes.
    typealias Action = OIDAuthStateAction
	
	
    var hasConfiguration:Bool {
        configuration != nil
    }
    
	/**
	Designated initializer.
	
	- parameter type: The authorization type to use
	- parameter server: The server these auth settings apply to
	- parameter settings: Authentication settings
	*/
    init(server: Server, issuer: URL) {
		self.server = server
        self.issuer = issuer
        discoverConfiguration(for: issuer)
	}
    
    init(server: Server, configuration: OIDServiceConfiguration) {
        self.server = server
        self.issuer = configuration.issuer
        self.configuration = configuration
    }
	
	
	// MARK: - Configuration
	
    func discoverConfiguration(for issuer:URL) {
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { [weak self] config, error in
            if let error = error {
                print("Error encountered:", error)
            }
            print("Config", config)
            self?.configuration = config
        }
    }
    
    func requestAuthorization(_ parameters: AuthorizationParameters, presenting: UIViewController) {
        guard let configuration = configuration else {
            print("Error: configuration is nil")
            return
        }
        
        let request = parameters.buildRequest(with: configuration)
        
        self.session = OIDAuthState.authState(byPresenting: request, presenting: presenting) { (state, error) in
            self.state = state
            if let error = error { print("Error authorizing:",error) }
        }
    }
	
	/**
	Reset auth, which includes setting authContext to nil and purging any known access and refresh tokens.
	*/
	func reset() {
		authContext = nil
        session?.cancel()
        session = nil
        state = nil
	}
    
    func performAction(additionalRefreshParameters: [String: String]? = nil, dispatchQueue: DispatchQueue = .main, action: @escaping Action) {
        guard configuration != nil else {
            print("Error: configuration is nil")
            return
        }
        guard let state = state else {
            print("Error: state is nil")
            return
        }
        guard state.isAuthorized else {
            print("Error: state is not authorized")
            return
        }
        
        state.performAction(freshTokens: action, additionalRefreshParameters: additionalRefreshParameters, dispatchQueue: dispatchQueue)

    }
	
    @discardableResult
	func handleRedirect(_ redirect: URL) -> Bool {
        guard let session = session else {
            print("Session is undefined")
            return false
        }
        
        return session.resumeExternalUserAgentFlow(with: url)
	}
	
}

