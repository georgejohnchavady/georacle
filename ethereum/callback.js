const getTodo = callback =>{
    setTimeout(() =>{
        return callback({text: 'complete code example'})
    }, 2000)
}

getTodo(todo =>{
    console.log(todo.text)
})

console.log("this is the first output!")
