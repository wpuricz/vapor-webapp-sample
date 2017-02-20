import Vapor
import HTTP

final class LoginController {

  func addRoutes(drop: Droplet) {
    	  drop.get("login", handler: login)
    }

  func login(request: Request) throws -> ResponseRepresentable {
    	return try drop.view.make("login")
    }
}
