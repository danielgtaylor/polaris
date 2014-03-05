# Polaris
Lightweight backend utilities for static websites. Currently implements sending email to configured addresses from HTML forms with optional attachments. Feel free to fork and add more features.

Point your static website toward the north star.

## Installation
You can install `polaris` via NPM, the [Node.js](http://nodejs.org/) package manager.

```bash
sudo npm install -g polaris
```

## Usage
Typically you would run Polaris like any other program, with the first argument being an optional configuration file:

```bash
polaris /path/to/my/config.json
```

You can also use Polaris directly from within Node:

```javascript
var polaris = require('polaris');

polaris.config.recipients = {
  test: {
    to: ['test@gmail.com'],
    title: 'Test title',
    allowFiles: false
  }
};

polaris.runServer();
```

It's also possible to use the Polaris request handler directly via the `http`, `connect`, or `express` modules. This means you can easily add it to an existing application as a new route:

```javascript
var express = require('express');
var polaris = require('polaris');

var app = express();

app.post('/email', polaris.handler);

app.listen(3000);
```

### Configuration
Polaris is configured via a simple JSON file. An example looks like:

```json
{
  "listen": {
    "host": "localhost",
    "port": 8080
  },
  "transport": {
    "name": "SMTP",
    "options": {
      "host": "smtp.mailgun.org",
      "secureConnection": true,
      "port": 465,
      "auth": {
        "user": "USERNAME",
        "pass": "PASSWORD"
      }
    }
  },
  "recipients": {
    "test": {
      "to": ["test@gmail.com"],
      "title": "Email subject title",
      "allowFiles": false
    }
  }
}
```

#### Email

The `transport` options correspond to [Nodemailer](http://www.nodemailer.com/docs/usage-example) `createTransport` arguments. The configuration above is for [MailGun](https://mailgun.com/), but many possible configurations exist. For example, for [Gmail](https://www.gmail.com/):

```json
...
"transport": {
  "name": "SMTP",
  "options": {
    "service": "Gmail",
    "auth": {
      "user": "USERNAME",
      "pass": "PASSWORD"
    }
  }
},
...
```

## Deployment
Some possible deployement scenarios follow.

### Heroku
[Heroku](https://devcenter.heroku.com/articles/getting-started-with-nodejs) uses git for deployments and supports NPM dependencies. Create a new project:

```bash
mkdir server
cd server

npm init
npm install --save polaris
```

##### main.js
```javascript
var polaris = require('polaris');

polaris.config.recipients = {
  test: {
    to: ['test@gmail.com'],
    title: 'Test title',
    allowFiles: false
  }
};

polaris.runServer();
```

##### Procfile
```
web: node main.js
```

Then set up the git repo and push to deploy:

```bash
git init
git add .
git commit -m 'Initial commit'

heroku create

git push heroku master
```

## Development
Feel free to fork and create pull requests. You should edit the `main.coffee` file since the `main.js` file is generated from it. Building the Javascript is easy:

```bash
npm run build
```

## License
Copyright &copy; 2014 Daniel G. Taylor

http://dgt.mit-license.org/
