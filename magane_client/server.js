const express = require('express');
const app = express();
const session = require('express-session');
const MySQLStore = require('express-mysql-session')(session);
const bodyParser = require('body-parser');
const mysql = require('mysql');
const server = app.listen(3000, function() {
  console.log("Express server has started on port 3000")
});
app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');
app.engine('html', require('ejs').renderFile);
app.use(express.static('public'));
app.use(bodyParser.urlencoded({
  extended: false
}));
//session
app.use(session({
  secret: '1234DSFs@ad1234!@#$asd',
  resave: false,
  saveUninitialized: true,
  store: new MySQLStore({
    host: 'localhost',
    port: 3307,
    user: 'root',
    password: 'gusdk9470',
    database: 'voter'
  })
}));
//router
const main_router = require('./router/main')(app);
const auth_router = require('./router/auth')(app);
//const register_router = require('./router/register')(app);