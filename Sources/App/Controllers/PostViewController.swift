import Vapor
import HTTP

final class PostViewController {

  
  

  func indexView(request:Request) throws -> ResponseRepresentable {
    let user: User?
    do {
        user = try request.auth.user() as? User
    }catch {
        return Response(redirect: "/login")
    }
    
  	let posts = try Post.all().makeNode()
  	let params = try Node(node: [
  		"posts": posts,
  		"name": user?.name
  		])
  	return try drop.view.make("post",params)
  }

  func addPost(request: Request) throws -> ResponseRepresentable {
  	guard let content = request.data["content"]?.string else {
  		throw Abort.badRequest
  	}

  	var post = Post(content: content)
  	try post.save()

  	return Response(redirect: "/posts")

  }
    
    func deletePost(request:Request, post: Post) throws -> ResponseRepresentable {
        // need to fix, we are getting content = "3" instead of id = 3
        try post.delete()
        return Response(redirect: "/posts")
    }

}
