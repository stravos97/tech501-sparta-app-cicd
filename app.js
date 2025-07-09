var express = require('express');
var app = express();
var exec = require('child_process').exec;
var mongoose = require('mongoose');
var Post = require('./models/post');

app.set('view engine' , 'ejs');

app.use(express.static('public'));

app.get('/' , function(req , res){

  res.render("index");

});

// connect to database
let dbConnected = false;
if (process.env.DB_HOST) {
  mongoose.connect(process.env.DB_HOST)
    .then(() => {
      console.log('MongoDB connected successfully.');
      dbConnected = true;
    })
    .catch(err => {
      console.error('MongoDB connection error:', err.message);
      dbConnected = false;
    });
}

// Define /posts route (always defined)
app.get("/posts", async function(req, res) {
  if (!dbConnected) {
    console.warn('Database not connected. Returning empty posts array.');
    return res.status(500).send('Database not connected'); // Return 500 if DB not connected
  }
  try {
    const posts = await Post.find({});
    res.json(posts);
  } catch (err) {
    console.error(err);
    return res.status(500).send(err);
  }
});

app.get('/fibonacci/:n' , function(req,res){

  // high cpu usage function
  var value = fibonacci(req.params.n);

  res.render("fibonacci" , {index:req.params.n, value:value});
});

// app.get("/hack/:command" , function(req,res){

//   var child = exec(req.params.command, function (error, stdout, stderr) {
//     res.render("hackable/index", {stdout:stdout, command:req.params.command});
//   });
// });

const port = 3000; // Define port

// Only start the server if this file is run directly (not required as a module)
if (require.main === module) {
  app.listen(port, () => {
    console.log(`Your app is ready and listening on port ${port}`);
  });
}

// deliberately poorly implemented fibonnaci
function fibonacci(n) {

  if(n == 0)
    return 0;

  if(n == 1)
    return 1;

  return fibonacci(n - 1) + fibonacci(n - 2);

}

module.exports = app; // Export the app for testing