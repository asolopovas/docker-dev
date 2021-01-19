let livereload = require('livereload')
let server = livereload.createServer({
    exts: ['html', 'css', 'js', 'png', 'gif', 'jpg', 'php', 'scss', 'twig']
})
server.watch(__dirname)
