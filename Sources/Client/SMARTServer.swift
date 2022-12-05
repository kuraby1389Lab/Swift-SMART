//
//  SMARTServer.swift
//  SMART-on-FHIR
//
//  Created by Pascal Pfiffner on 6/11/14.
//  Copyright (c) 2014 SMART Health IT. All rights reserved.
//

import Foundation
import AppAuth
import NotificationCenter

/**
Representing the FHIR resource server a client connects to.

This implementation holds on to an `Auth` instance to handle authentication. It is automatically instantiated with properties from the
settings dictionary provided upon `Client` initalization or from the server's cabability statement.

The server's cabability statement is automatically downloaded the first time it's needed for various tasks, such as instantiating the `Auth`
instance or validating/executing operations.

A server manages its own NSURLSession, either with an optional delegate provided via `sessionDelegate` or simply the system shared
session. Subclasses can change this behavior by overriding `createDefaultSession` or any of the other request-related methods.

*/
open class SMARTServer: FHIROpenServer {
	
	/// The service URL as a string, as specified during initalization to be used as `aud` parameter.
	public final let aud: String
	
	/// An optional name of the server; will be read from cabability statement unless manually assigned.
	public final var name: String?
	
	/// The authorization to use with the server.
	private(set) var authAgent: SMARTAuthAgent?
	
	
	/// The refresh token provided with the access token; Issuing a refresh token is optional at the discretion of the authorization server.
	public var refreshToken: String? {
        authAgent?.state?.refreshToken
	}
	
	var mustAbortAuthorization = false
	
	/**
	Main initializer. Makes sure the base URL ends with a "/" to facilitate URL generation later on.
	
	- parameter baseURL: The base URL of the server
	*/
	public required init(baseURL: URL, auth: [String : Any]? = nil) {
		aud = baseURL.absoluteString
		super.init(baseURL: baseURL, auth: nil)
		
	}
    
    public convenience init(baseURL: URL, issuer: URL) {
        self.init(baseURL: baseURL)
        self.authAgent = SMARTAuthAgent(server: self, issuer: issuer)
    }
    
    public convenience required init(baseURL: URL, configuration: OIDServiceConfiguration) {
        self.init(baseURL: baseURL)
        self.authAgent = SMARTAuthAgent(server: self, configuration: configuration)
    }
	
    
    public var isAuthorized: Bool {
        authAgent?.state?.isAuthorized ?? false
    }
    
	
	// MARK: - Requests
	
	/**
	Instantiate the server's default URLSession.
	
	- returns: The URLSession created
	*/
//	override open func createDefaultSession() -> URLSession {
//		if let delegate = sessionDelegate {
//			return Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: delegate, delegateQueue: nil)
//		}
//		return super.createDefaultSession()
//	}
//
//	/**
//	Return a URLRequest for the given url, possibly already signed, that can be further configured.
//
//	- parameter url: The URL the request will work against
//	- returns:       A preconfigured URLRequest
//	*/
//	override open func configurableRequest(for url: URL) -> URLRequest {
//		return auth?.signedRequest(forURL: url) ?? super.configurableRequest(for: url)
//	}
//
//
//	// MARK: - FHIROpenServer
//
//	open override func perform(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
//		logger?.debug("SMART", msg: "--->  \(request.httpMethod ?? "???") \(request.url?.description ?? "No URL")")
//		logger?.trace("SMART", msg: "REQUEST\n\(String(describing: request))\n---")
//		return super.perform(request: request) { data, response, error in
//			self.logger?.trace("SMART", msg: "RESPONSE\n\(response.debugDescription)\n---")
//			self.logger?.debug("SMART", msg: "<---  \((response as? HTTPURLResponse)?.statusCode ?? 999) (\(data?.count ?? 0) Byte)")
//			completionHandler(data, response, error)
//		}
//	}
//
//
//	// MARK: - Server Capability Statement
//
//	override open func didSetCapabilityStatement(_ cabability: CapabilityStatement) {
//		if nil == name, let cName = cabability.name?.string {
//			name = cName
//		}
//		super.didSetCapabilityStatement(cabability)
//	}
//
//	override open func didFindCapabilityStatementRest(_ rest: CapabilityStatementRest) {
//		super.didFindCapabilityStatementRest(rest)
//
//		// initialize Auth; if we can't find a suitable Auth we'll use one for "no auth"
//		if let security = rest.security {
//			auth = Auth(fromCapabilitySecurity: security, server: self, settings: authSettings)
//		}
//		if nil == auth {
//			auth = Auth(type: .none, server: self, settings: authSettings)
//			logger?.debug("SMART", msg: "Server seems to be open, proceeding with none-type auth")
//		}
//	}
//
//
//	// MARK: - Authorization
//
//	/// The auth credentials currently in use by the receiver.
//	open var authClientCredentials: (id: String, secret: String?, name: String?)? {
//		if let clientId = auth?.oauth?.clientId, !clientId.isEmpty {
//			return (id: clientId, secret: auth?.oauth?.clientSecret, name: auth?.oauth?.clientName)
//		}
//		return nil
//	}
//
//	/**
//	Attempt to instantiate our `Auth` instance from `authSettings` and assign to our `auth` ivar.
//	*/
//	func instantiateAuthFromAuthSettings() -> Bool {
//		var authType: AuthType? = nil
//		if let typ = authSettings?["authorize_type"] as? String {
//			authType = AuthType(rawValue: typ)
//		}
//		if nil == authType || .none == authType! {
//			if let _ = authSettings?["authorize_uri"] as? String {
//				if let _ = authSettings?["token_uri"] as? String {
//					authType = .codeGrant
//				}
//				else {
//					authType = .implicitGrant
//				}
//			}
//		}
//		if let type = authType {
//			auth = Auth(type: type, server: self, settings: authSettings)
//			return true
//		}
//		return false
//	}
//
//	/**
//	Ensures that the server is ready to perform requests before calling the callback.
//
//	Being "ready" in this case entails holding on to an `Auth` instance. Such an instance is automatically created if either the client
//	init settings are sufficient (i.e. contain an "authorize_uri" and optionally a "token_uri" and a "client_id" or "registration_uri") or
//	after the cabability statement has been fetched.
//	*/
//	open func ready(callback: @escaping (FHIRError?) -> ()) {
//		if nil != auth || instantiateAuthFromAuthSettings() {
//			callback(nil)
//			return
//		}
//
//		// if we haven't initialized the auth instance we likely didn't fetch the server metadata yet
//		getCapabilityStatement() { error in
//			if nil != self.auth {
//				callback(nil)
//			}
//			else {
//				callback(error ?? FHIRError.error("Failed to detect the authorization method from server metadata"))
//			}
//		}
//	}
    


    
    
    
    
//
//	/**
//	Ensures that the receiver is ready, then calls the auth method's `authorize()` method.
//
//	- parameter properties: The auth properties to use
//	- parameter callback:   Callback to call when authorization is complete, providing the chosen patient (if the patient scope was
//	                        provided) or an error, if any
//	*/
//	open func authorize(with properties: SMARTAuthProperties, callback: @escaping ((_ patient: Patient?, _ error: Error?) -> Void)) {
//		ready() { error in
//			if self.mustAbortAuthorization {
//				self.mustAbortAuthorization = false
//				callback(nil, nil)
//			}
//			else if nil != error || nil == self.auth {
//				callback(nil, error ?? FHIRError.error("Client error, no auth instance created"))
//			}
//			else {
//				self.auth!.authorize(with: properties) { parameters, error in
//					if self.mustAbortAuthorization {
//						self.mustAbortAuthorization = false
//						callback(nil, nil)
//					}
//					else if let error = error {
//						callback(nil, error)
//					}
//					else if let patient = parameters?["patient_resource"] as? Patient {		// native patient list auth flow will deliver a Patient instance
//						callback(patient, nil)
//					}
//					else if let patientId = parameters?["patient"] as? String {
//						Patient.read(patientId, server: self) { resource, error in
//							self.logger?.debug("SMART", msg: "Did read patient \(String(describing: resource)) with error \(String(describing: error))")
//							callback(resource as? Patient, error)
//						}
//					}
//					else {
//						callback(nil, nil)
//					}
//				}
//			}
//		}
//	}
//
//	/**
//	Aborts ongoing authorization and requests session.
//	*/
//	open func abort() {
//		abortAuthorization()
//		abortSession()
//	}
//
//	func abortAuthorization() {
//		mustAbortAuthorization = true
//		if nil != auth {
//			auth!.abort()
//		}
//	}
	
	/**
	Resets authorization state - including deletion of any known access and refresh tokens.
	*/
	func reset() {
		// abort()
		authAgent?.reset()
	}
    
    @discardableResult
    public func handleRedirect(_ redirect: URL) -> Bool {
        guard let auth = authAgent else {
            print("Session is undefined")
            return false
        }
        
        return auth.handleRedirect(redirect)
    }
	
	
	// MARK: - Client Registration
	
	/**
	Runs dynamic client registration unless the client has a client id (or no registration URL is known). Since this happens automatically
	during `authorize()` you probably won't need to call this method explicitly.
	
	- parameter callback: The callback to call when completed or failed; if both json and error is nil no registration was attempted
	*/
//	open func registerIfNeeded(callback: @escaping ((_ json: OAuth2JSON?, _ error: Error?) -> Void)) {
//		ready() { error in
//			if nil != error || nil == self.auth {
//				callback(nil, error ?? FHIRError.error("Client error, no auth instance created"))
//			}
//			else if let oauth = self.auth?.oauth {
//				oauth.registerClientIfNeeded(callback: callback)
//			}
//			else {
//				callback(nil, nil)
//			}
//		}
//	}
//
//	func forgetClientRegistration() {
//		auth?.forgetClientRegistration()
//		auth = nil
//	}
}

#if os(iOS)
public extension SMARTServer {
    func requestAuthorization(_ parameters: SMARTAuthParameters, presenting: UIViewController) {
        authAgent?.requestAuthorization(parameters, presenting: presenting)
    }
}
#endif

#if os(macOS)
public extension SMARTServer {
    func requestAuthorization(_ parameters: SMARTAuthParameters, presenting: NSWindow) {
        authAgent?.requestAuthorization(parameters, presenting: presenting)
    }
}
#endif

