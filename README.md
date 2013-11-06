# Mock API Server

A Full-Featured  API Mock Server

![Demo](https://raw.github.com/zlx/API-mock-server/master/public/image/demo.png)

## Installation

### Install Mongodb

   [Install MongoDB](http://docs.mongodb.org/manual/installation/)

### Clone the Project

    git clone git@github.com:zlx/API-mock-server.git

### Install Dependancy

    bundle install --path=vendor/bundle

## Usage

### Mongodb Config

Configurate mongodb in mongoid.yml like below:
   
    development:
      sessions:
        default:
          database: api_mock_server
          hosts: 
            - localhost:27017



### Start Server
    
    rackup

### Visit

    http://localhost:9292/admin
    
*Default username/password*: admin/admin

## HowTo

### How to config admin username/password ?


Config admin_user and admin_password in [config.rb](https://github.com/zlx/API-mock-server/blob/master/config.rb)


### How to config Top Namespace ?

**Top Namespace** is used for specific api version.

for an example, if you config `top_namespace = "/api/v1"`, then you must visit "/api/v1/me" to reach "/me" route which you created.

Top namespace is a global setting, so it will take an effect for every routes you created.

To config top_namespace in in [config.rb](https://github.com/zlx/API-mock-server/blob/master/config.rb)


## Test

### Mock Data

    ruby seed.rb

### Test the service using a curl or your favourite tool

    curl http://localhost:4000
    { "hello": "world" }

### Postman

[https://github.com/a85/POSTMan-Chrome-Extension](https://github.com/a85/POSTMan-Chrome-Extension)

## Deploy on Server

### work with unicorn

[Guide for setup unicorn for rack app](http://recipes.sinatrarb.com/p/deployment/nginx_proxied_to_unicorn)

[unicorn config example](https://github.com/zlx/API-mock-server/blob/master/unicorn.rb.example)
