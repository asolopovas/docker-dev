let livereload = require('livereload');
let server = livereload.createServer();
server.watch(__dirname);
