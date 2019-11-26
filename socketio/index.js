var app = require('express')();
var http = require('http').createServer(app);
var io = require('socket.io')(http, { origins: '*:*'});

app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

io.on('connection', function(socket){
  console.log('a user connected');
  socket.on('message', function(message) {
	console.log('message ' + message);
	io.emit('message', message);
  });
});

http.listen(3000, function(){
  console.log('listening on *:3000');
});

/* console.log("Server started");
var Msg = '';
var WebSocketServer = require('ws').Server
    , wss = new WebSocketServer({port: 3000});
    wss.on('connection', function(ws) {
        ws.on('message', function(message) {
        console.log('Received from client: %s', message);
        ws.send('Server received from client: ' + message);
    });
 }); */