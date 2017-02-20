//
//  User.swift
//  AuthTemplate
//
//  Created by Anthony Castelli on 10/29/16.
//
//

import HTTP
import Fluent
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import Auth
import Vapor

final class User: Auth.User {

    // Field for the Fluent ORM
    var exists: Bool = false
    
    // Database Fields
    var id: Node?
    
    var username: String
    var email: String = ""
    var name: String = ""
    var password: String = ""
    
    var apiKey: String = URandom().secureToken
    var apiSecret: String = URandom().secureToken
    
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        var user: User?
        
        switch credentials {
        case let credentials as UsernamePassword:
            let fetchedUser = try User.query().filter("username", credentials.username).first()
            if let password = fetchedUser?.password, password != "", (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }
            
        case let credentials as APIKey:
            user = try User.query().filter("api_key", credentials.id).filter("api_secret", credentials.secret).first()
            
        default:
            throw UnsupportedCredentialsError()
        }
        
        if let user = user {
            return user
        } else {
            throw IncorrectCredentialsError()
        }
    }
    
    static func register(credentials: Credentials) throws -> Auth.User {
        var newUser: User
        
        switch credentials {
        case let credentials as UsernamePassword: newUser = User(credentials: credentials)
        default: throw UnsupportedCredentialsError()
        }
        
        if try User.query().filter("username", newUser.username).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AccountTakenError()
        }
        
    }
    
    static func register(credentials: Credentials, parameters: [String : String]) throws -> Auth.User {
        if var user = try self.register(credentials: credentials) as? User {
            user.addParameters(parameters)
            try user.save()
            return user
        }
        
        throw InvalidInput()
    }
    
    init(credentials: UsernamePassword) {
        self.username = credentials.username
        self.password = BCrypt.hash(password: credentials.password)
    }
    
    init(node: Node, in context: Context) throws {
        self.id = node["id"]
        self.username = try node.extract("username")
        self.email = try node.extract("email")
        self.name = try node.extract("name")
        self.password = try node.extract("password")
        self.apiKey = try node.extract("api_key")
        self.apiSecret = try node.extract("api_secret")
    }
    
    func addParameters(_ parameters: [String : String]) {
        if let email = parameters["email"] {
            self.email = email
        }
        
        if let name = parameters["name"] {
            self.name = name
        }
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": self.id,
            "username": self.username,
            "email": self.email,
            "name": self.name,
            "password": self.password,
            "api_key": self.apiKey,
            "api_secret": self.apiSecret
        ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("users") { users in
            users.id()
            users.string("username")
            users.string("email")
            users.string("name")
            users.string("password")
            users.string("api_key")
            users.string("api_secret")
            
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
}

extension Request {
    func user() throws -> User {
        guard let user = try auth.user() as? User else {
            throw "Invalid user type"
        }
        return user
    }
}

extension String: Error {

}

