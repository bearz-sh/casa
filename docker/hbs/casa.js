const generate = require("generate-password").generate;
const fs = require("fs");
const path = require("path");
const os = require("os");
const Cryptr = require("cryptr");
const bcrypt = require('bcrypt');
const shelljs = require("shelljs");
const { join } = require("path");


let casa = function(){}

casa.register = function(Handlebars) {
    const bcryptSaltRounds = 10;
    const hb = Handlebars;   
    let passwordsCount = 0;
    let isWindows = process.platform === 'win32';
    let passwords = {};
    let hostname = os.hostname();
    let secretsDir = path.resolve(path.join(__dirname, "..", "etc", "secrets"));
    let pwDb = path.join(secretsDir, `${hostname}.secrets.db`);
    let pwKey = path.join(secretsDir, `${hostname}.secrets.key`);
    let rootDir = path.resolve(path.join(__dirname, ".."));
   
    let createSecret = function(length, special) {
        special = special || "_-#@~[]=^:;"
        generate({})
        return generate({
            length: length,
            symbols: special.toString()
        });
    }

    let key = "";
    if (!fs.existsSync(pwKey))
    {
        key = createSecret(20);
        fs.writeFileSync(pwKey, key, { 'encoding': 'utf8'});
    }
    else 
    {
        key = fs.readFileSync(pwKey, { 'encoding': 'utf8'});
    }


    var cryptr = new Cryptr(key);

    if (fs.existsSync(pwDb))
    {
        let json = fs.readFileSync(pwDb, {encoding: 'utf8'});
        passwords = JSON.parse(json);
    }
    else 
    {
        let json = JSON.stringify(passwords);
        fs.writeFileSync(pwDb, json, {encoding: "utf8"});
    }

    hb.registerHelper('is-windows', () => {
        return process.platform === 'win32'
    });

    hb.registerHelper('is-darwin', () => {
        return process.platform === 'darwin'
    });

    hb.registerHelper('shell', (script) => {
        return shelljs.exec(script);
    });

    hb.registerHelper('to-bool', (value) => {
        if(value === null || typeof(value) === 'undefined') {
            return false;
        }

        if (typeof(value) === 'boolean') {
            return value;
        }

        if (typeof(value) === 'number') {
            if(value === 1)
                return true;

            return false;
        }

        if (typeof(value) === 'string') {
            let v = value.toLowerCase();

            switch(v) {
                case "yes":
                case "y":
                case "true":
                case "1":
                    return true;
            }
        }

        return false;
    });

    hb.registerHelper('get-env-bool', (name) => {
        let value = process.env[name];

        if(value === null || typeof(value) === 'undefined') {
            return false;
        }

        value = value.toLowerCase();
        switch(value) {
            case "1":
            case "yes":
            case "y":
            case "true":
                return true;
        }

        return false;
    });


    hb.registerHelper('get-env', (name, defaultValue) => {
        if(isWindows) {
            switch(name) {
                case "HOST":
                    return process.env["COMPUTERNAME"];
                case "USER":
                    return process.env["USERNAME"];
                case "HOME":
                    return process.env["USERPROFILE"];
            }
        }

        return process.env[name] || defaultValue;
    });



    hb.registerHelper("concat-target", (key, target) => {
        if(!target) {
            target = process.env["TARGET"] || process.env['NODE_ENV'] || "dev"
        }

        return `${target}/${key}`;
    });

    hb.registerHelper('bcrypt-password', (key, rounds) => {
        if (key === null || typeof(key) === 'undefined' || (typeof(key) === 'string' && key.trim().length === 0)) {
            return "";
        }

        var password = passwords[key];
        if(!password) {
            return "";
        }

        password = cryptr.decrypt(password);
        rounds = rounds || bcryptSaltRounds;

        return bcrypt.hashSync(password, rounds);
    });

    hb.registerHelper("cat", (options) => {
        let r = "";
        
        if(arguments.length > 1) {
            let l = arguments.length - 1;
            for(var i = 0; i < l; i++) {
                let file = arguments[i];

                if(typeof(file) === "string") {
                    if(file.startsWith("./") || file.startsWith(".\\")) {
                        file = file.substring(2);
                        file = path.join(rootDir, file);
                    }

                    if (file.startsWith("~/") || file.startsWith("~\\")) {
                        file = file.substring(2);
                        file = path.join(os.homedir(), file);
                    }

                    if (fs.existsSync(file)) {
                        r += readFileSync(arguments[i], {"encoding": "utf-8"});
                        r += "\n";
                    }
                }
            }
        }
        return r;
    });

    hb.registerHelper('new-password', (key, length, special) => {
        let l = 16
        if (typeof(key) === 'string') {
            passwords[key] = ''
        } else {
            key = passwordsCount.toString();
        }

        var pw = passwords[key];

        if(pw) {
            pw = cryptr.decrypt(pw);
            return pw;
        }


        if (length !== null) {
            if(typeof(length) === 'string' || typeof(length) === 'number') {
                let parsedValue = parseInt(length);
                if (!Number.isNaN(parsedValue)) {
                    if (parsedValue > 0) {
                        l = parsedValue
                    }
                }
            }    
        }

        special ||= "_-#@~[]=^:;"

        var pw = generate({
            length: l,
            symbols: special,
        });

        passwords[key] = cryptr.encrypt(pw);
        fs.writeFileSync(pwDb, JSON.stringify(passwords), "utf8");

        return pw;
    });

}

module.exports = casa 