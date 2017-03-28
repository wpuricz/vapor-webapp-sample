import Vapor
import HTTP

final class PostViewController {

  
  func indexView(request:Request) throws -> ResponseRepresentable {
    
    let user = try request.auth.user() as! User
    let posts = try Post.query().filter("user_id", user.id!).all().makeNode()
    
  	let params = try Node(node: [
  		"posts": posts,
  		"name": user.name
  	])
  	return try drop.view.make("post",params)
  }

  func addPost(request: Request) throws -> ResponseRepresentable {
  	guard let content = request.data["content"]?.string else {
  		throw Abort.badRequest
  	}

  	var post = Post(content: content)
    post.user_id = (try request.auth.user() as! User).id!
  	try post.save()

  	return Response(redirect: "/secure/posts")

  }
    
    func deletePost(request:Request, post: Post) throws -> ResponseRepresentable {
        // need to fix, we are getting content = "3" instead of id = 3
        try post.delete()
        return Response(redirect: "/secure/posts")
    }

}
