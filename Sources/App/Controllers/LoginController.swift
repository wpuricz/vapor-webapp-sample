import Vapor
import HTTP
import Turnstile
import TurnstileCrypto
import TurnstileWeb


final class LoginController {

    func addRoutes(drop: Droplet) {
    	drop.get("login", handler: loginView)
        drop.get("register", handler: registerView)
        drop.post("register", handler: register)
        drop.post("login", handler: login)
        drop.get("logout", handler: logout)
    }

    func loginView(request: Request) throws -> ResponseRepresentable {
    	return try drop.view.make("login")
    }
  
    func registerView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("register")
    }
    
    func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.logout()
        return Response(redirect: "/login")
    }
    
    func login(request: Request) throws -> ResponseRepresentable {
        
        guard let username = request.data["username"]?.string, let password = request.data["password"]?.string else {
            let params = try Node(node: ["error":"true"])
            return try drop.view.make("login", params)
        }
        let credentials = UsernamePassword(username: username, password: password)
        
        
        do {
            //let _ = try User.authenticate(credentials: credentials)
            try request.auth.login(credentials, persist: true)
            return Response(redirect: "/secure/posts")
        } catch let e as TurnstileError {
            let params = try Node(node: ["error":"Invalid username or password"])
            return try drop.view.make("login", params)
        }
        
        
    }

    func register(request: Request) throws -> ResponseRepresentable {
        // Get our credentials
        guard let username = request.data["username"]?.string, let password = request.data["password"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        let credentials = UsernamePassword(username: username, password: password)
        
        // Get any other parameters we need
        var parameters = [String : String]()
        guard let email = request.data["email"]?.string else {
            return try JSON(node: ["error": "Missing Email"])
        }
        parameters["email"] = email
        
        guard let name = request.data["name"]?.string else {
            return try JSON(node: ["error": "Missing Full Name"])
        }
        parameters["name"] = name
        
        // Try to register the user
        do {
            try _ = User.register(credentials: credentials, parameters: parameters)
            //try User.login(username:username,password:password)
            //return try JSON(node: ["success": true, "user": request.user().makeNode()])
            return Response(redirect: "/secure/posts")
        } catch let e as TurnstileError {
            throw Abort.custom(status: Status.badRequest, message: e.description)
        }
    }
}
