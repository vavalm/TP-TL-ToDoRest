<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>My Todo Application</title>
    <style type="text/css">
        <!--
        body {
            background-color:Gainsboro;
            color:DarkBlue;
            font-family:arial;
        }
        h1 {background-color:Darkblue;
            color:White;}

        input {
            color:DarkBlue;
            background-color:AliceBlue;
            font-size:12px;
            font-family:arial;
        }
        select {
            color:DarkBlue ;
            background-color:AliceBlue;
            font-size:12px;
            font-family:arial;
        }
        -->
    </style>
    <script type="text/javascript">
        var req;
        var todosArray = [];

        function getTodosRequest() {
            req = new XMLHttpRequest();
            req.onreadystatechange = getTodosRequestHandler;
            req.open("GET","rest/todos", true); // mode asynchrone
            req.send();
        }

        function getTodosRequestHandler() {
            if (req.readyState == 4 && req.status == 200) {
                // var table = document.getElementById("todoTable");
                var res = req.responseXML;
                var todos = res.getElementsByTagName("todo");
                var l = todos.length;

                eraseTodosList();
                for (var i = 0; i < l; i++) {
                    var item = todos.item(i);
                    var desc = item.getElementsByTagName('description').item(0).firstChild.nodeValue;
                    var id =  item.getElementsByTagName('id').item(0).firstChild.nodeValue;
                    var deadline = item.getElementsByTagName('deadline').item(0).firstChild.nodeValue;
                    var done = item.getElementsByTagName('done').item(0).firstChild.nodeValue;
                    var date = deadline.split(".");
                    var day = parseInt(date[0]), month = parseInt(date[1]), year = parseInt(date[2]);
                    var todo = new Todo(id, desc, new Date(year, month, day, 0, 0, 0), done)
                    addTodoInList(todo);
                }
            }
        }

        function Todo(id, desc, deadline, done) {
            this.id = id;
            this.desc = desc;
            this.done = done;
            this.deadline = deadline;
        }
        Todo.prototype.toString = function() {
            return "[" + this.id + " - " +  this.desc + ":" + this.formatedDate() + "]";
        }
        Todo.prototype.toXML = function() {
            var dstr = this.formatedDate();
            var res =  "<todo>" +
                "<id>" + this.id + "</id>" +
                "<description>" + this.desc + "</description>" +
                "<deadline>" + dstr + "</deadline>" +
                "<done>" + this.done + "</done>" +
                "<tag>None</tag>" +
                "</todo>";
            return res;

        }
        Todo.prototype.formatedDate = function() {
            return this.deadline.getDate() + "." + this.deadline.getMonth() + "." + this.deadline.getFullYear();
        }

        function eraseTodosList() {
            var todosOptions = document.getElementById('todoList').options;
            todosArray = []
            var l = todosOptions.length;
            for (var i=1; i <= l; i++) {
                todosOptions.remove(0);
            }
        }

        function selectTodoInList() {
            var todosList = document.getElementById('todoList');
            var index1 = todosList.selectedIndex;
            var option = todosList.options[index1];
            var index2 = option.value
            var todo = todosArray[index2]
            fillInput(todo);
        }

        function fillInput(todo) {
            var date = todo.deadline
            document.getElementById('ident').value = todo.id;
            document.getElementById('desc').value = todo.desc;
            document.getElementById('day').value = date.getDate();
            document.getElementById('month').value = date.getMonth()+1;
            document.getElementById('year').value = date.getFullYear();
            document.getElementById('done').selected = todo.done
        }

        function addTodoInList(todo) {
            var todosList = document.getElementById('todoList');
            var option=document.createElement('option');
            todosList.add(option, null);
            var i = todosArray.length + 1;
            todosArray[i] = todo
            option.text= todo.toString()
            option.value= i
        }


        function addTodoRequest(todo) {
            req = new XMLHttpRequest();
            req.onreadystatechange = addTodoRequestHandler;
            req.open("POST","rest/todos", true); // mode asynchrone
            req.setRequestHeader("content-type", "application/xml");
            req.send(todo.toXML());
        }

        function addTodoRequestHandler() {
            if (req.readyState == 4) {
                if (req.status == 201) {
                    getTodosRequest();
                } else {
                    alert("Error:" + req.statusText)
                }
            }
        }

        function addTodo() {
            var ident = document.getElementById('ident').value;
            var desc = document.getElementById('desc').value;
            var day = parseInt(document.getElementById('day').value);
            var month =  parseInt(document.getElementById('month').value);
            var year =  parseInt(document.getElementById('year').value);
            var todo = new Todo(ident, desc, new Date(year, month-1, day, 0, 0, 0, 0), false)
            addTodoRequest(todo)
        }

        function putTodoRequest(todo) {
            req = new XMLHttpRequest();
            req.onreadystatechange = putTodoRequestHandler;
            var todoId = todo.id;
            req.open("PUT","rest/todos/" + todoId, true); // mode asynchrone
            req.setRequestHeader("content-type", "application/xml");
            req.send(todo.toXML());
        }

        function putTodoRequestHandler() {
            if (req.readyState == 4) {
                if (req.status == 204) {
                    getTodosRequest();
                } else {
                    alert("Error:" + req.statusText)
                }
            }
        }

        function putTodo() {
            var ident = document.getElementById('ident').value;
            var desc = document.getElementById('desc').value;
            var day = parseInt(document.getElementById('day').value);
            var month =  parseInt(document.getElementById('month').value);
            var year =  parseInt(document.getElementById('year').value);
            var todo = new Todo(ident, desc, new Date(year, month-1, day, 0, 0, 0, 0), false)
            putTodoRequest(todo)
        }

        function deleteTodoRequest(todo) {
            req = new XMLHttpRequest();
            req.onreadystatechange = deleteTodoRequestHandler;
            var uri = "rest/todos" + "/" + todo.id;
            req.open("DELETE", uri, true); // mode asynchrone
            req.send();

        }

        function deleteTodoRequestHandler() {
            if (req.readyState == 4) {
                if (req.status == "204") {
                    getTodosRequest();
                } else {
                    alert("Error:" + req.statusText)
                }
            }
        }

        function deleteSelectedTodo() {
            var todosList = document.getElementById('todoList')
            var index1 = todosList.selectedIndex;
            var option = todosList.options[index1];
            var index2 = option.value
            var todo = todosArray[index2]
            deleteTodoRequest(todo)
        }


    </script>
</head>
<body>
<H1>Todo Application</H1>
<select name="todoList" id="todoList" size="4" onClick="selectTodoInList()">
</select>
<br/>
<table id="todoTable" border="1">
    <tr><td>Id</td><td><input type="text" id="ident"/></td></tr>
    <tr><td>Description</td><td><input type="text" id="desc"/></td></tr>
    <tr><td>Date</td><td><input type="text" id="day" size="2" maxlength="2"/>/<input type="text" id="month" size="2" maxlength="2"/>/<input type="text" id="year" size="4" maxlength="4"/></td></tr>
    <tr><td>Done</td><td><input type="checkbox" id="done"/></td></tr>
</table>
<br>
<input type="button" value="Add" onClick="addTodo()"/>
<input type="button" value="Modify" onClick="putTodo()"/>
<input type="button" value="Remove" onClick="deleteSelectedTodo()"/>
<script type="text/javascript">getTodosRequest()</script>
</body>
</html>