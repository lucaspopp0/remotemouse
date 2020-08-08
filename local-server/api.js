const os = require('os');
const ip = require('ip');
const axios = require('axios');

const inst = axios.create({
    baseURL: 'http://remotemouse.us-west-2.elasticbeanstalk.com'
});

function currentConfig() {
    return {
        name: os.hostname(),
        address: ip.address(),
        port: 9000
    }
}

function uploadSelf() {
    return inst.post('/hosts', currentConfig());
}

function deleteSelf() {
    return inst.post('/deletehost', currentConfig());
}

module.exports = {
    currentConfig,
    uploadSelf,
    deleteSelf
}