const getTodo = () =>{
return new Promise((resolve, reject) =>{

    setTimeout(() =>{

        let error = false
        if(!error){
            resolve({text: 'complete code example'})
        }
        else
            reject()
    }, 2000)

})


}

async function fetchTodo(){
    try{
        const todo = await getTodo();
        return todo
    }
    catch{
        console.log("error caught in fetchTodo() !")
    }

}

fetchTodo().then((todo) =>{
    console.log(todo.text)
})
.catch(()=>console.log("error!"))
