import Vapor
import Auth
import HTTP
import Cookies
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import Fluent
import Foundation
import VaporPostgreSQL


let drop = Droplet(
    providers: [VaporPostgreSQL.Provider.self]
)

drop.preparations.append(User.self)
drop.preparations.append(Post.self)
drop.middleware.append(TrustProxyMiddleware())
drop.middleware.append(AuthMiddleware<User>())


drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

// Route with raw DB connection
drop.get("version") { request in
	if let db = drop.database?.driver as? PostgreSQLDriver {
			let version = try db.raw("SELECT version()")
			return try JSON(node: version)
		}else{
			return "no db connection"
		}

}

// Don't cache leaf so we can reload without restarting
(drop.view as? LeafRenderer)?.stem.cache = nil


// MARK: Secure Web Page Routes

let protected = Auth.LoginRedirectMiddleware(loginRoute: "/login")
drop.grouped(protected).group("secure") { secure in

    let postView: PostViewController = PostViewController()
    
    secure.get("posts", handler: postView.indexView)
    secure.post("posts", handler: postView.addPost)
    secure.post("posts",Post.self, "delete", handler: postView.deletePost)
    
}


// MARK: API Routes

drop.group("api") { api in
    api.group("v1") { v1 in
        let z = "m"
        let usersController = UsersController()
        
        // Registration
        v1.post("register", handler: usersController.register)
        
        // Log In
        v1.post("login", handler: usersController.login)

        // Log Out
        v1.post("logout", handler: usersController.logout)
        
        // Secured Endpoints
        let protect = ProtectMiddleware(error: Abort.custom(status: .unauthorized, message: "Unauthorized"))
        v1.group(BasicAuthMiddleware(), protect) { secured in
            
            // Get my data
            secured.get("me", handler: usersController.me) 
            
            secured.resource("posts",PostController())
            
            // Update my data
            secured.post("update", handler: usersController.update)           

        }
    }
}

// MARK: Login Route
let loginController: LoginController = LoginController()
loginController.addRoutes(drop: drop)

drop.run()
