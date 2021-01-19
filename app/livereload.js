let livereload = require('livereload');
let server = livereload.createServer({
    exts: [html,css,js,png,gif,jpg,php,php5,py,rb,erb,coffee,scss,twig]
});
server.watch(__dirname);
