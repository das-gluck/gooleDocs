//console.log("Hello World");   // print -> dart

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const http = require('http');


const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");

const PORT = process.env.PORT | 3001 ;

const app = express();
var server = http.createServer(app);
var io = require("socket.io")(server);

app.use(cors());
app.use(express.json());
app.use(authRouter);
app.use(documentRouter);

const DB = "mongodb+srv://300rupiyadega:Y3bXSlKToIGqppKA@cluster0.lgrmf3h.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";




mongoose.connect(DB).then( ()=> {
    console.log("connection successful !! ");
}).catch((err) => {
    console.log(err);
});

io.on("connection" , (socket) => {
    socket.on('join' , (documentId) => {
        socket.join(documentId);
//        console.log('joined!!!');
    });

    socket.on('typing' , (data) => {
        socket.broadcast.to(data.room).emit('changes', data);
    });

});


server.listen(PORT, "0.0.0.0", () => {
    console.log(`------connected at port ${PORT}`);
});

