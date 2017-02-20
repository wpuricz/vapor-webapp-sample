# postgres-template
Template for starting vapor applications with user authentication and postgresql

To start a new project using this template, run this command

    vapor new [app name here] --template=https://github.com/wpuricz/postgres-template
    cd [app name here]

Login to postgres and create your database

	create database [my database]

Then update the credentials stored in /Config/secrets/postgresql.json

	cd [app name here]
	vapor build && vapor run

Additionally, there is a dummy route in main.swift to test the database connection which can be tested by putting the url below in the browser:

    http://localhost:8080/version

Authentication Routes

	POST http://localhost:8080/api/v1/login
	POST http://localhost:8080/api/v1/register
	POST http://localhost:8080/api/v1/me
	POST http://localhost:8080/api/v1/logout
	POST http://localhost:8080/api/v1/update
	GET http://localhost:8080/api/v1/posts

