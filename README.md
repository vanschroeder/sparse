sParse
=======

A *sparse* Parse API for Backbone

#### Why sParse?

Parse.com provides a full featured and robust [Javascript API](https://parse.com/docs/api_libraries) implementation as a general purpose solution intended to work within all manner of javascript frameworks, but...

 - It's big... >80k big when minified
 - It only emulates Backbone and doesn't have all Backbone features
 - Using Sparse API within a Backbone App results in having two core libraries, a massive overlap of labor

Those issues go against the ideals of developers who believe Web Apps should be small, fast and without duplication of labor. So it made sense to create a "not so general purpose" suite of Classes that would allow both new and existing Backbone Applications to integrate with the Parse REST API without adding substantial code overhead, or duplicating Backbone functionality in a seperate code base.

**sParse's design Goals are as follows:**

 - Be small, compact and simple
 - Go wherever Backbone can go with no added dependencies
 - 'Drop In' to any existing Backbone Application
 - Quickly 'Convert' your existing Parse API app into a sParse Backbone App
 - Provide complete Parse REST API coverage (in progress)


With that said...


DANGER WILL ROBINSON!!!
-----------------------

sParse is presently in Alpha and API Coverage is not complete, in fact it's missing core features such as Roles, Relations and Query Objects
Due to the lack of these features, sParse is not recommended for production use at this time.
Check back soon though, as these features are in the works.


Basic Usage
-----------

#### Accessing a Parse Collection
Case: We wish to get all records from the Posts Object

*javascript* example:
```
sparse.APP_ID = XXXXXXXXXX;
sparse.REST_KEY = XXXXXXXXXX;
Posts = sparse.Collection.extend({
     className:'Posts',
    model:(sparse.Model.extend({
		className:'Post',
		defaults:{
			body:"",
			userKey:"",
			contentKey:""
		}
	}));
})
posts = new Posts();
posts.fetch();

``` 


*coffeescript* example:
```
sparse.APP_ID = XXXXXXXXXX
sparse.REST_KEY = XXXXXXXXXX
class Posts extends sparse.Collection
	model:(class Post extends sparse.Model
		defaults:
			body:""
			userKey:""
			contentKey:""
	)
posts = new Posts()
posts.fetch();
``` 

sParse is wired to make life a little easier for [Coffeescript](http://coffeescript.org/) users by grabbing the classname and automatically setting the `className` param for you, with an Inflection to plualize the Model Class Name for you, mapping `Model` *Post* to the *Posts* Object.
  
Converting Parse Apps 
-----------

Simply rename your Parse.Object and Parse.Collection references to sparse.Model and sparse.Collection accordingly

```
var ParseTodo = Parse.Object.extend({
  className: "Todo"
});
 
var sparseTodo = sparse.Model.extend({
  className: "Todo"
});
```


or in *coffeescript*:
```
class ParseTodo extends Parse.Object
  className: "Todo"
 
class sparseTodo extends sparse.Model
```


Users 
-----------

#### Register a New User

*javascript* example:
```
sparse.APP_ID = XXXXXXXXXX;
sparse.REST_KEY = XXXXXXXXXX;
newUser = new sparse.User({
	username:"EdTesty",
	password:"s3cr3t",
	email:"ed.testy.testing.com"
})
newUser.save({
	success:function(model, response, options) {
		console.log("user successfully created"
	},
	error:function(model, response, options) {
		console.log("user creation failed"
	}
});

```

*coffeescript* example:
```
sparse.APP_ID = XXXXXXXXXX;
sparse.REST_KEY = XXXXXXXXXX;
newUser = new sparse.User
	username:"EdTesty"
	password:"s3cr3t"
	email:"ed.testy.testing.com"
newUser.save
	success:(model, response, options)->
		console.log "user successfully created"
	error:(model, response, options)->
		console.log "user creation failed"
``` 

#### User Login

*javascript* example:
```
sparse.APP_ID = XXXXXXXXXX;
sparse.REST_KEY = XXXXXXXXXX;
user = new sparse.User({
	username:"EdTesty",
	password:"s3cr3t"
})
user.login({
	success:function(model, response, options) {
		console.log("user successfully created");
	},
	error:function(model, response, options) {
		console.log("user creation failed");
	}
});

```

*coffeescript* example:
```
sparse.APP_ID = XXXXXXXXXX;
sparse.REST_KEY = XXXXXXXXXX;
user = new sparse.User
	username:"EdTesty",
	password:"s3cr3t"
user.login
	success:(model, response, options)->
		console.log "user successfully created"
	error:(model, response, options)->
		console.log "user creation failed"
```


#### User Password Reset

*javascript* example:
```
sparse.APP_ID = XXXXXXXXXX;
sparse.REST_KEY = XXXXXXXXXX;
pwReset = new sparse.User({
	email:"ed.testy@test.com"
})
pwReset.resetPassword({
	success:function(model, response, options) {
		console.log("user successfully created");
	},
	error:function(model, response, options) {
		console.log("user creation failed");
	}
});

```

*coffeescript* example:
```
sparse.APP_ID = XXXXXXXXXX;
sparse.REST_KEY = XXXXXXXXXX;
pwReset = new sparse.User
	email:"ed.testy@test.com"
pwReset.resetPassword
	success:(model, response, options)->
		console.log "user successfully created"
	error:(model, response, options)->
		console.log "user creation failed"
```


Batch Operations
--------------

Sometimes you may want to throw a whole bunch of data at the Parse API all at once. For that we use the Parse API's Batch Request feature, which is supported by sParse via a special Batch Collection Object.

sparse.Batch is Object Agnostic, so you may add any type of sparse.Model object for `create`, `upate` and `delete` operations.
For more info on Parse Batch read the [API Docs](https://parse.com/docs/rest#objects-batch)

*javascript* example:
```
sparse.APP_ID = XXXXXXXXXX;
sparse.REST_KEY = XXXXXXXXXX;
Posts = sparse.Collection.extend({
 	className:'Posts',
	model:(sparse.Model.extend({
		className:'Post',
		defaults:{
			body:"",
			userKey:"",
			contentKey:""
		}
	}));
})
posts = new Posts();
posts.fetch({
	success:function(model,response,options)
	{
		# send our loaded Data Set to Batch
		(new sparse.Batch(model).exec({
			success:function(model,response,options) {
				console.log("Batch imported successfully");
			},
			error:function(model,response,options) {
				console.log("Batch import failed");
			},
		}); 
	}
});
``` 


*coffeescript* example: 
```
sparse.APP_ID = XXXXXXXXXX
sparse.REST_KEY = XXXXXXXXXX
class Posts extends sparse.Collection
	url:->
		"data/posts.dump.json"
	model:(class Post extends sparse.Model
		defaults:
			body:""
			userKey:""
			contentKey:""
	)
posts = new Posts()
posts.fetch
	success:(model,response,options)=>
		# send our loaded Data Set to Batch
		(new sparse.Batch model).exec
			success:(model,response,options)=>
				console.log "Batch imported successfully"
			error:(model,response,options)=>
				console.log "Batch import failed"

```

View the Demo
--------------

[View The Online Demo @github.io](http://vancarney.github.io/sparse/demo/)

Additionally a working Connect Server based Demo App is available in the [sParse-Demo Repo](https://github.com/vancarney/sparse-demo.git)
Git and NodeJS+NPM are required to install and run

```
$ git clone https://github.com/vancarney/sparse-demo.git && cd sparse-demo && npm install && npm start
```