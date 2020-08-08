const net = require('net');
const ip = require('ip');
const robot = require('robotjs');
const api = require('./api.js');

var lastIP;
var currentIP = ip.address();;
var server;

let intervalId = setInterval(() => {
    lastIP = currentIP;
    currentIP = ip.address();

    if (lastIP != currentIP) {
        if (server) {
            server.close();
            api.deleteSelf();
        }

        startServer();
    }
}, 5 * 60 * 1000);

function startServer() {
    currentIP = ip.address();

    server = net.createServer();
    server.on('connection', socket => {
        const remoteAddress = socket.remoteAddress + ':' + socket.remotePort;
        console.log(`New incoming connection from ${remoteAddress}`);

        // Trailing ||| used to separate messages on the other end
        socket.write('node|||');
    
        socket.setEncoding('utf8');
    
        socket.once('close', () => {
            console.log(`Connection to ${remoteAddress} closed`);
        });
    
        socket.on('data', data => {
            let pieces = data.trim().split(':');
            console.log(data.trim());

            switch (pieces[0]) {
                case 'ping':
                    break;

                case 'mv':
                    let [dx, dy] = pieces[1].split(',').map(Number);

                    if (isNaN(dx) || isNaN(dy)) {
                        console.log(data.trim() + ' (bad)');
                        // console.log(`Bad input: ${data}. Ignoring`);
                        socket.write('-> Bad input. Please input data in the format dx,dy\n');
                        return;
                    }
            
                    let {x, y} = robot.getMousePos();
                    robot.moveMouse(x + dx, y + dy);
                    break;
                
                case 'clk':
                    let pos = robot.getMousePos();
                    robot.mouseClick();
                    break;

                case 'key':
                    if (pieces.length == 2) {
                        robot.keyTap(pieces[1]);
                    } else {
                        robot.keyTap(pieces[1], pieces[2].split(','));
                    }
                    break;

                case 'type':
                    robot.typeString(pieces[1]);
                    break;

                default:
                    break;
            }
        });
    
        socket.on('error', err => {
            console.log(`Connection ${remoteAddress} error: ${err.message}`);
        });
    });

    // Listen on port 9000
    server.listen(9000, function() {
        console.log(`Server listening on ${currentIP}:9000`);
        
        api.uploadSelf()
        .then(response => {
            console.log('Sent ID to AWS server');
        }).catch(err => {
            console.log('Error logging to AWS');
            console.error(err);
        });
    });
}

startServer();

process.stdin.resume();

function exitHandler(options, exitCode) {
    api.deleteSelf()
    .then(response => {
        if (options && options.exit) process.exit();
    })
    .catch(err => {
        if (options && options.exit) process.exit();
    });
}

process.on('exit', exitHandler.bind(null));
process.on('SIGINT', exitHandler.bind(null, {exit:true}));
process.on('SIGUSR1', exitHandler.bind(null, {exit:true}));
process.on('SIGUSR2', exitHandler.bind(null, {exit:true}));
process.on('uncaughtException', exitHandler.bind(null, {exit:true}));