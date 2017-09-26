package iad.rest.todo;

import javax.ws.rs.*;
import javax.ws.rs.core.*;
import javax.xml.bind.JAXBElement;
import java.net.URI;
import java.util.*;
import java.util.List;

@Path("/todos")
public class TodoResource {

    @Context
    UriInfo uriInfo;
    @Context
    Request request;

    @GET
    @Produces(MediaType.APPLICATION_XML)
    public List<Todo> getTodo(){
        List<Todo> todos = new LinkedList<Todo>();
        Todo todo = new Todo("1", "Faire courses", new GregorianCalendar().toString(), Collections.singletonList("Important"));
        todos.addAll(Todo.valuesStore());
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

    @Path("/{id}")
    @DELETE
    public Response deleteTodo(@PathParam("id") String id){
        Response response;

        if (Todo.containStore(id)) {
            Todo.removeStore(id);
            System.out.println(uriInfo.getAbsolutePath().toString() + "::" + request.toString());
            response = Response.noContent().build();
        } else {
            response = Response.status(Response.Status.NOT_FOUND).build();
        }
        return response;
    }

}
