import Vapor
import HTTP

final class PostViewController {

  
  func addRoutes(drop: Droplet) {
  	  drop.get("posts", handler: indexView)
  	  drop.post("posts", handler: addPost)
      drop.post("posts",Post.self, "delete", handler: deletePost)
  }

  func indexView(request:Request) throws -> ResponseRepresentable {

  	let posts = try Post.all().makeNode()
  	let params = try Node(node: [
  		"posts": posts
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
