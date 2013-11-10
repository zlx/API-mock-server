# Mock API Server

A Full-Featured  API Mock Server  

[![Code Climate](https://codeclimate.com/github/zlx/API-mock-server.png)](https://codeclimate.com/github/zlx/API-mock-server) [![Build Status](https://travis-ci.org/zlx/API-mock-server.png?branch=master)](https://travis-ci.org/zlx/API-mock-server)

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

    cp mongoid.yml.example mongoid.yml


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

### How to redirect your routes to mock server


## Add redirect route at the end of your route.rb

```ruby
constraints(Domain::Mockapi) do
  get "/*any", to: redirect { |p, req| "http://<<your-mockapi-server>>/#{req.fullpath}" }
end
```

## create domain/mockapi.rb file

```ruby
module Domain

  APIs = %w{
  }

  class Mockapi
    def self.matches? request
      api = request.fullpath.sub(/\?.*/, "")
      api.in? APIs
    end
  end

end
```

Assign your mock apis in `APIs`


[wiki](https://github.com/zlx/API-mock-server/wiki/Redirect-your-specific-routes-to-mockapi)


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
