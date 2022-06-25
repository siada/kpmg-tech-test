#!/bin/bash -xe
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
apt-get install -y nodejs

npm install --prefix /var/www/html cors dotenv express mysql ordinal
cat <<- "EOF" > /var/www/html/.env
DB_HOST=${db_ip}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_NAME=${db_name}
APP_PORT=${app_port}
DB_PORT=${db_port}
EOF

cat <<- "EOF" > /var/www/html/index.js
const express = require("express"),
    ordinal = require("ordinal"),
    mysql = require("mysql"),
    cors = require("cors");
require("dotenv").config();

const app = express();
app.use(cors());
const port = process.env.APP_PORT;

app.get('/', (req, res) => {
    try {
        const conn = MysqlConnect();

        conn.query("SELECT num FROM visitors", (err, results, fields) => {

            if (results.length == 0) {
                conn.query("INSERT INTO visitors(num) VALUES (2)", (e1, r1, f1) => { // insert 2 because the _next_ visitor is the 2nd visitor
                    conn.destroy();
                    res.send(ordinal(1));
                });
            } else {
                conn.query("UPDATE visitors SET num = num + 1", () => {
                    conn.destroy();
                });
                res.send(ordinal(results[0].num));
            }
        });

    } catch (e) {
        res.send(`Problem connecting to DB $${e}`)
    }
});

app.listen(port, () => {
    console.log(`Listening on ::$${port}`);
    const dbCreateConn = MysqlConnect(true);
    dbCreateConn.query("CREATE DATABASE IF NOT EXISTS `" + process.env.DB_NAME + "`", () => {
        dbCreateConn.destroy();
        const conn = MysqlConnect();
        conn.query("CREATE TABLE IF NOT EXISTS `visitors` ( `num` INT );", () => {
            conn.destroy();
        });
    });
});

function MysqlConnect(ignoreDb = false) {
    const conn = mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: ignoreDb ? undefined : process.env.DB_NAME,
        port: process.env.DB_PORT
    });

    conn.connect((err) => {
        if (err) throw err;
    });

    return conn;
}
EOF

nohup sh -c 'cd /var/www/html; node /var/www/html/index.js' & disown