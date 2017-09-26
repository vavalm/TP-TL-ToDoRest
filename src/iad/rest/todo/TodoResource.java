package iad.rest.todo;

import javax.servlet.annotation.WebInitParam;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.ws.rs.*;
import javax.ws.rs.core.*;
import javax.xml.bind.JAXBElement;
import java.awt.*;
import java.net.URI;
import java.util.*;
import java.util.List;

//@WebServlet(urlPatterns = "/rest/*")
@Path("/todos")
public class TodoResource {

    @Context
    UriInfo uriInfo;
    @Context
    Request request;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public List<Todo> getTodo(){
        List<Todo> todos = new LinkedList<Todo>();
        Todo todo = new Todo("1", "Faire courses", new GregorianCalendar().toString(), Collections.singletonList("Important"));
        todos.add(todo);
        return todos;
    }

    @POST
    @Consumes(MediaType.APPLICATION_XML)
    public Response createTodo(JAXBElement<Todo> xmltodo){
        Todo todo = xmltodo.getValue();
        Response response;
        String id = todo.getId();

        if (Todo.containStore(id)) {
            response = Response.noContent().build();
        } else {
            Todo.putStore(id, todo);
            String uriStr = uriInfo.getAbsolutePath().toString();
            System.out.println(uriStr + "::" + request.toString());
            URI uri = URI.create(uriStr + "/" + id);
            response = Response.created(uri).build();
        }
        return response;
    }

    
}
