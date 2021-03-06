should      = require 'should'
Argument    = require '../../../lib/argumenta/objects/argument'
Proposition = require '../../../lib/argumenta/objects/proposition'
Fixtures    = require '../../../test/fixtures'

describe 'Argument', ->

  defaults =
    title: 'The Argument Title'
    premises: [
      'The first premise.'
      'The second premise.'
    ]
    conclusion: 'The conclusion.'
    metadata:
      discussions_count: 2

  { title, premises, conclusion, metadata } = defaults

  describe 'new Argument( title, premises, conclusion, metadata )', ->

    it 'should create a new instance', ->
      argument = new Argument title, premises, conclusion, metadata
      argument.should.be.an.instanceOf Argument
      argument.propositions.length.should.equal 3
      argument.title.should.equal 'The Argument Title'
      argument.premises.length.should.equal 2
      argument.premises[0].should.be.an.instanceOf Proposition
      argument.premises[0].text.should.equal 'The first premise.'
      argument.conclusion.should.be.an.instanceOf Proposition
      argument.conclusion.text.should.equal 'The conclusion.'
      argument.metadata.should.eql metadata

    it 'should create an invalid instance if params are missing', ->
      argument = new Argument null, null, null
      argument.validate().should.equal false

  describe 'new Argument( params )', ->
    it 'should create a new, equivalent instance', ->
      argument = new Argument title: title, premises: premises, conclusion: conclusion
      expected = new Argument title, premises, conclusion
      should.ok argument.equals expected

    it 'should create an invalid instance if params are missing', ->
      argument = new Argument {}
      argument.validate().should.equal false

  describe 'children()', ->
    it 'should return an array with premises and conclusion', ->
      argument = new Argument title, premises, conclusion
      argument.children().length.should.equal 3
      for child in argument.children()
        child.should.be.an.instanceOf Proposition

  describe 'objectRecord()', ->
    it 'should return the argument object record', ->
      argument = new Argument title, premises, conclusion
      record = argument.objectRecord()
      record.should.equal """
        argument

        title The Argument Title
        premise d7574671f9327761109829761d97d7001b60cd43
        premise 503db2aa0a6d31e73f66c3efd8e15f92ee7d11be
        conclusion 3940b2a6a3d5778297f0e37a06109f9d3dcffe6d

        """

  describe 'sha1()', ->
    it 'should return the sha1 sum of the object record', ->
      argument = new Argument title, premises, conclusion
      sha1 = argument.sha1()
      sha1.should.equal '7077e1ce31bc8e9d2a88479aa2d159f2f9de4856'

  describe 'equals()', ->
    it 'should return true if arguments are equal', ->
      argumentA = new Argument title, premises, conclusion
      argumentB = new Argument title, premises, conclusion
      argumentA.equals(argumentB).should.equal true

    it 'should return false if arguments are not equal', ->
      argumentA = new Argument title, premises, conclusion
      argumentB = new Argument title, premises, 'different-conclusion'
      argumentA.equals(argumentB).should.equal false

  describe 'validate()', ->

    it 'should return true if all components are valid', ->
      argument = new Argument title, premises, conclusion
      argument.validate().should.equal true

    it 'should return false if missing title', ->
      argument = new Argument '', premises, conclusion
      argument.validate().should.equal false

    it 'should return false if title above max length', ->
      chars = ("a" for i in [1..Argument.MAX_TITLE_LENGTH + 1])
      longTitle = chars.join ''
      argument = new Argument longTitle, premises, conclusion
      argument.validate().should.equal false

    it 'should return false if missing premises', ->
      argument = new Argument title, [ '' ], conclusion
      argument.validate().should.equal false

    it 'should return false if missing conclusion', ->
      argument = new Argument title, premises, ''
      argument.validate().should.equal false

  describe 'repo()', ->
    it 'should return the default repo name (slugified title)', ->
      argument = new Argument title, premises, conclusion
      argument.repo().should.equal 'the-argument-title'

  describe 'data()', ->
    it 'should return a plain object with argument data', ->
      argument = new Argument title, premises, conclusion
      data = argument.data()
      data.should.eql {
        title: title
        premises: premises
        conclusion: conclusion
        object_type: 'argument'
        sha1: argument.sha1()
        repo: argument.repo()
      }

    it 'should include argument metadata if present', ->
      argument = new Argument defaults
      data = argument.data()
      data.metadata.should.eql metadata

    it 'should include commit data if present', ->
      argument = new Argument title, premises, conclusion
      argument.commit = Fixtures.validCommit()
      data = argument.data()
      data.commit.should.eql argument.commit.data()

    it 'should include propositions data if metadata present', ->
      argument = new Argument title, premises, conclusion
      for p in argument.propositions
        p.metadata = Fixtures.validPropositionMetadata(p)
      data = argument.data()
      data.propositions[0].should.eql argument.propositions[0].data()

  describe 'Argument.sanitizeTitle( text )', ->
    it 'should replace newlines with spaces', ->
      text = '\ntitle:\n\nsubtitle\n'
      result = Argument.sanitizeTitle text
      result.should.equal 'title: subtitle'

    it 'should trim leading and trailing spaces', ->
      text = '  title: subtitle  '
      result = Argument.sanitizeTitle text
      result.should.equal 'title: subtitle'

    it 'should trim leading or trailing spaces', ->
      text1 = '  title: subtitle'
      text2 = 'title: subtitle  '
      result1 = Argument.sanitizeTitle text1
      result2 = Argument.sanitizeTitle text2
      result1.should.equal 'title: subtitle'
      result2.should.equal 'title: subtitle'

  describe 'Argument.sanitizePremises( premises )', ->
    it 'should array wrap a single premise string', ->
      unwrapped = 'the premise text'
      premises = Argument.sanitizePremises( unwrapped )
      premises.length.should.equal 1
      premises[0].should.equal unwrapped

  describe 'Argument.slugify( title )', ->
    it 'should replace spaces with hyphens', ->
      @title = 'My Argument'
      slug = Argument.slugify(@title)
      slug.should.equal 'my-argument'

    it 'should replace periods with hyphens', ->
      @title = 'No.6'
      slug = Argument.slugify(@title)
      slug.should.equal 'no-6'

    it 'should merge consecutive hyphens', ->
      @title = 'Mt. Gox'
      slug = Argument.slugify(@title)
      slug.should.equal 'mt-gox'
