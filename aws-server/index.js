const express = require('express');
const bodyParser = require('body-parser');

const app = express();

app.use(bodyParser.urlencoded());
app.use(bodyParser.json());

var currentConnections = [];

app.get('/hosts', (req, res) => {
    res.json(currentConnections);
})

app.post('/hosts', (req, res) => {
    const { name, address, port } = req.body;
    console.log('New host ' + JSON.stringify({ name, address, port }));
    currentConnections.push({ name, address, port });
    res.end();
});

app.post('/clear', (req, res) => {
    console.log('Cleared hosts');
    currentConnections = [];
    res.end();
})

app.post('/deletehost', (req, res) => {
    const { name, address, port } = req.body;
    let index = currentConnections.findIndex(conn => conn.name === name && conn.address === address && conn.port === port);

    if (index >= 0) {
        currentConnections.splice(index, 1);
        console.log('Deleted host ' + JSON.stringify({ name, address, port }));
    } else {
        console.log('Unable to delete host ' + JSON.stringify({ name, address, port }));
    }

    res.end();
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log('Server running on port ' + PORT);
});