var chai = require('chai');
var chaiHttp = require('chai-http');
var chaiJquery = require('chai-jquery');
var server = require('../app');
var should = chai.should();

chai.use(chaiHttp);

describe('Homepage', function() {
  it('should display the homepage at / GET', function(done) {
    chai.request(server)
      .get('/')
      .end(function(err, res){
        res.should.have.status(200);
        done();
      });
  });
  it('should contain the word Sparta at / GET', function(done) {
    chai.request(server)
      .get('/')
      .end(function(err, res){
        res.text.should.contain('Sparta')
        done();
      });
  });
});

describe('Blog Posts', function() {
  it('should display a list of 100 posts at /posts GET', function(done) {
    chai.request(server)
      .get('/posts')
      .end(function(err, res){
        res.should.have.status(200);
        res.should.be.json; // Assert that the response is JSON
        res.body.should.be.an('array'); // Assert that the body is an array
        res.body.length.should.be.eql(100); // Assert that there are 100 posts

        // Optionally, check properties of the first post
        if (res.body.length > 0) {
          res.body[0].should.have.property('title');
          res.body[0].should.have.property('body'); // Changed from 'content'
        }
        done();
      });
  });
});

describe('Fibonacci', function() {
  it('should display the correct fibonacci value at /fibonacci/10 GET', function(done) {
    chai.request(server)
      .get('/fibonacci/10')
      .end(function(err, res){
        res.should.have.status(200);
        res.text.should.contain('55');
        done();
      });
  });
});
