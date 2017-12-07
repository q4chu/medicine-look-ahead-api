var config = require('./config');
var db = require('mysql');

function Mysql() {
    this._host = config.mysql.host;
    this._user = config.mysql.user;
    this._password = config.mysql.password;
    this._db = config.mysql.db;
};

Mysql.prototype.reconnect = function(cb) {
    if (this._connection) {
        this._connection.end();
        this._connection = false;
    }
    this.connect(cb);
};

Mysql.prototype.connect = function(cb) {
    var me = this;
    logger.debug('connecting ...');

    this._connection = db.createConnection({
        host : this._host,
        user : this._user,
        password : this._password,
        database: this._db
    });
    this._connection.connect(function(err) {
        if (err)  {
            logger.debug(err);
        } else {
            logger.debug('db connected')
            if (cb) {
                cb();
            }
        }
    });

    this._connection.on('error', function(err) {
        logger.debug(err);
        me.reconnect();
    });
};

Mysql.prototype.exec = function(sql, cb) {
    var me = this;
    this._connection.query(sql, function(err, result, fields) {
        if (err) {
            logger.debug(err);
            if (err.code === 'PROTOCOL_ENQUEUE_AFTER_FATAL_ERROR') {
                me.reconnect(function(){
                    me.exec(sql, cb);
                });
            }
            if (cb) {
                cb(false);
            }
        } else {
            if(!result.length) {
                logger.debug("query empty");
            }
            if (cb) {
                cb(result, fields);
            }
        }
    });
};

module.exports = Mysql;