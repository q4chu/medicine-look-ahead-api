const express = require('express');

const app = express();

var data = {key:'data',value:10};

app.all('/',(req,res,next) => {
    console.log("request to /");
    next();
});

app.get('/', (req,res) => res.send('hello world'));
app.get('/data',(req,res) => res.send(data));

var server = app.listen(3000,() => {
    var port = server.address().port;
    var address = server.address().address;
    console.log("running server on " + address + ": " + port);
});
