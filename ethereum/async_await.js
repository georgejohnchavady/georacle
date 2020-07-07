const getTodo = () =>{
return new Promise((resolve, reject) =>{

    setTimeout(() =>{

        let error = true
        if(!error){
            resolve({text: 'complete code example'})
        }
        else
            reject()
    }, 2000)

})


}

async function fetchTodo(){
    const todo = await getTodo();
    return todo
}

fetchTodo().then((todo) =>{
    console.log(todo.text)
})
.catch(()=>console.log("error!"))
