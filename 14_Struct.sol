// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

contract Struct {
    struct Todo {
        string text;
        bool completed;
    }

    Todo[] public todos;

    function create(string memory _text) public {
        todos.push(Todo(_text, false));

        // 2 
        // Todo({
        //     text:_text,
        //     completed:false
        // });

        // 3 
        // Todo memory todo;
        // todo.text = _text;
        // todos.push(todo);
    }

    function get(uint _index) public view returns(string memory, bool) {
        Todo storage todo = todos[_index];
        return(todo.text, todo.completed);
    }

    function completed(uint _index) public {
        Todo storage todo = todos[_index];
        todo.completed = true;
    }
}