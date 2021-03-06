const express = require('express');
const mysql = require('./core/mysql');
const bodyParser = require('body-parser');
const global = require('./core/global');
const app = express();

//mysql
global.mysql = new mysql();
global.mysql.connect();

const lookAhead = require('./core/lookAhead');

app.all('*',(req,res,next) => {
    console.log("request to /");
    res.header('Access-Control-Allow-Origin', '*');
    next();
});

app.use(express.static('public'));

app.get('/lookahead/dinId/:id',(req,res) => {
    var id = req.params.id;
    if(!isNaN(id)) {
        lookAhead.searchByDin(req.params.id,res);
    } else {
        res.status(400).send('invalid id');
    }
});

app.get('/lookahead/guess/:guess',(req,res) => {
    lookAhead.searchByGuess(req.params.guess,res);
});

app.get('/lookahead/category/:category',(req,res) => {
    lookAhead.searchByCategory(req.params.category,res);
});

app.get('/lookahead/drug/:drug',(req,res) => {
    lookAhead.searchByName(req.params.drug,res);
});

app.use((req,res,next) => {
    res.send('invalid url');
});

var server = app.listen(3000,() => {
    var port = server.address().port;
    var address = server.address().address;
    console.log("running server on " + address + ": " + port);
});
