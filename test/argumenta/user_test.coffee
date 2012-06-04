User = require '../../lib/argumenta/user'

describe 'User', ->
  it 'should create a user instance', ->
    params =
      username: 'tester'
      password: 'tester12'
      email:    'tester@xyz.com'
    user = new User params
    user.should.be.an.instanceof User
    user.username.should.equal 'tester'
    user.password.should.equal 'tester12'
    user.email.should.equal    'tester@xyz.com'
