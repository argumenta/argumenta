should        = require 'should'
fixtures      = require '../../../test/fixtures'
Tags          = require '../../../lib/argumenta/objects/tags'
Tag           = Tags.Tag
SupportTag    = Tags.SupportTag
DisputeTag    = Tags.DisputeTag
CitationTag   = Tags.CitationTag
CommentaryTag = Tags.CommentaryTag

describe 'Tag', ->

  targetType = 'proposition'
  targetSha1 = '0123456789abcdef000000000000000000000000'
  sourceType = 'argument'
  sourceSha1 = '1a1a1a1a1a1a1a1a000000000000000000000000'
  citationText = 'The citation text, with URL: http://wikipedia.org/wiki/Citation'
  commentaryText = 'The commentary analysis, up to a few paragraphs...'

  describe 'new Tag( tagType, params... )', ->
    it 'should create a new support tag', ->
      tag = new Tag('support', targetType, targetSha1, sourceType, sourceSha1)
      tag.should.be.an.instanceOf SupportTag
      tag.validate().should.equal true

    it 'should create a new dispute tag', ->
      tag = new Tag('dispute', targetType, targetSha1, sourceType, sourceSha1)
      tag.should.be.an.instanceOf DisputeTag
      tag.validate().should.equal true

    it 'should create a new citation tag', ->
      tag = new Tag('citation', targetType, targetSha1, citationText)
      tag.should.be.an.instanceOf CitationTag
      tag.validate().should.equal true

    it 'should create a new commentary tag', ->
      targetTypeB = 'argument'
      tag = new Tag('commentary', targetTypeB, targetSha1, commentaryText)
      tag.should.be.an.instanceOf CommentaryTag
      tag.validate().should.equal true

    it 'should throw an object error if tag type is invalid', ->
      badFunc = -> new Tag( 'bad-type', targetType, targetSha1, sourceType, sourceSha1 )
      badFunc.should.throw Tag.Errors.Object

  describe 'validate()', ->
    it 'should fail if target type is invalid', ->
      tag = new Tag('support', 'bad-type', targetSha1, sourceType, sourceSha1)
      tag.validate().should.equal false

    it 'should fail if target sha1 is invalid', ->
      tag = new Tag('support', targetType, 'bad-sha1', sourceType, sourceSha1)
      tag.validate().should.equal false

    it 'should fail if source type is invalid', ->
      tag = new Tag('support', targetType, targetSha1, 'bad-type', sourceSha1)
      tag.validate().should.equal false

    it 'should fail if source sha1 is invalid', ->
      tag = new Tag('support', targetType, targetSha1, sourceType, 'bad-sha1')
      tag.validate().should.equal false

  describe 'equals()', ->
    it 'should return true if tags are equal', ->
      tagA = new Tag 'support', targetType, targetSha1, sourceType, sourceSha1
      tagB = new Tag 'support', targetType, targetSha1, sourceType, sourceSha1
      tagA.equals(tagB).should.equal true

    it 'should return false if tags are not equal', ->
      tagA = new Tag 'support', targetType, targetSha1, sourceType, sourceSha1
      tagB = new Tag 'dispute', targetType, targetSha1, sourceType, sourceSha1
      tagA.equals(tagB).should.equal false

describe 'SupportTag', ->

  targetType = 'proposition'
  targetSha1 = '0123456789abcdef000000000000000000000000'
  sourceType = 'argument'
  sourceSha1 = '1a1a1a1a1a1a1a1a000000000000000000000000'

  describe 'new SupportTag( targetType, targetSha1, sourceType, sourceSha1 )', ->
    it 'should create a new support tag instance', ->
      supportTag = new SupportTag( targetType, targetSha1, sourceType, sourceSha1 )
      supportTag.should.be.an.instanceOf SupportTag
      supportTag.should.be.an.instanceOf Tag
      supportTag.tagType.should.equal 'support'
      supportTag.targetType.should.equal 'proposition'
      supportTag.targetSha1.should.equal '0123456789abcdef000000000000000000000000'
      supportTag.sourceType.should.equal 'argument'
      supportTag.sourceSha1.should.equal '1a1a1a1a1a1a1a1a000000000000000000000000'
      supportTag.validate().should.equal true

  describe 'new SupportTag( options )', ->
    it 'should create a new support tag instance', ->
      tag1 = fixtures.validSupportTag()
      options = tag1.data()
      tag2 = new SupportTag( options )
      should.ok tag1.equals tag2

  describe 'objectRecord()', ->
    it 'should return a support tag object record', ->
      tag = new SupportTag(targetType, targetSha1, sourceType, sourceSha1 )
      record = tag.objectRecord()
      record.should.equal """
        tag

        tag_type support
        target proposition 0123456789abcdef000000000000000000000000
        source argument 1a1a1a1a1a1a1a1a000000000000000000000000

      """

  describe 'sha1()', ->
    it 'should return the sha1 of the object record', ->
      tag = new SupportTag(targetType, targetSha1, sourceType, sourceSha1 )
      tag.sha1().should.equal '2fcda77e243e4a7dc8fd9f3aa24c3392f7b59d20'

  describe 'data()', ->
    it 'should return the tag data as a plain object', ->
      tag1 = fixtures.validSupportTag()
      tag2 = new Tag tag1.data()
      should.ok tag1.equals tag2

describe 'DisputeTag', ->

  targetType = 'proposition'
  targetSha1 = '0123456789abcdef000000000000000000000000'
  sourceType = 'argument'
  sourceSha1 = '1a1a1a1a1a1a1a1a000000000000000000000000'

  describe 'new DisputeTag( targetType, targetSha1, sourceType, sourceSha1 )', ->
    it 'should create a new dispute tag instance', ->
      disputeTag = new DisputeTag( targetType, targetSha1, sourceType, sourceSha1 )
      disputeTag.should.be.an.instanceOf DisputeTag
      disputeTag.should.be.an.instanceOf Tag
      disputeTag.tagType.should.equal 'dispute'
      disputeTag.targetType.should.equal 'proposition'
      disputeTag.targetSha1.should.equal '0123456789abcdef000000000000000000000000'
      disputeTag.sourceType.should.equal 'argument'
      disputeTag.sourceSha1.should.equal '1a1a1a1a1a1a1a1a000000000000000000000000'
      disputeTag.validate().should.equal true

  describe 'new DisputeTag( options )', ->
    it 'should create a new dispute tag instance', ->
      tag1 = fixtures.validDisputeTag()
      options = tag1.data()
      tag2 = new DisputeTag( options )
      should.ok tag1.equals tag2

  describe 'objectRecord()', ->
    it 'should return a dispute tag object record', ->
      tag = new DisputeTag(targetType, targetSha1, sourceType, sourceSha1 )
      record = tag.objectRecord()
      record.should.equal """
        tag

        tag_type dispute
        target proposition 0123456789abcdef000000000000000000000000
        source argument 1a1a1a1a1a1a1a1a000000000000000000000000

      """

  describe 'sha1()', ->
    it 'should return the sha1 of the object record', ->
      tag = new DisputeTag(targetType, targetSha1, sourceType, sourceSha1 )
      tag.sha1().should.equal 'dad237cb552c9ecbfa67afa3774a620ea90e8ad6'

  describe 'data()', ->
    it 'should return the tag data as a plain object', ->
      tag1 = fixtures.validDisputeTag()
      tag2 = new Tag tag1.data()
      should.ok tag1.equals tag2

describe 'CitationTag', ->

  targetType = 'proposition'
  targetSha1 = '0123456789abcdef000000000000000000000000'
  citationText = 'The citation text, with URL: http://wikipedia.org/wiki/Citation'

  describe 'new CitationTag( targetType, targetSha1, citationText )', ->
    it 'should create a new citation tag instance', ->
      citationTag = new CitationTag( targetType, targetSha1, citationText )
      citationTag.should.be.an.instanceOf CitationTag
      citationTag.should.be.an.instanceOf Tag
      citationTag.tagType.should.equal 'citation'
      citationTag.targetType.should.equal 'proposition'
      citationTag.targetSha1.should.equal '0123456789abcdef000000000000000000000000'
      citationTag.citationText.should.equal 'The citation text, with URL: http://wikipedia.org/wiki/Citation'
      citationTag.validate().should.equal true

  describe 'new CitationTag( options )', ->
    it 'should create a new citation tag instance', ->
      tag1 = fixtures.validCitationTag()
      options = tag1.data()
      tag2 = new CitationTag( options )
      should.ok tag1.equals tag2

  describe 'validate()', ->
    it 'should return false unless targetType is proposition', ->
      citationTag = new CitationTag( 'argument', targetSha1, citationText )
      citationTag.validate().should.equal false
      citationTag.validationError.message.should.equal "Citation target type must be 'proposition'."

  describe 'objectRecord()', ->
    it 'should return a citation tag object record', ->
      tag = new CitationTag( targetType, targetSha1, citationText )
      record = tag.objectRecord()
      record.should.equal """
        tag

        tag_type citation
        target proposition 0123456789abcdef000000000000000000000000
        citation_text The citation text, with URL: http://wikipedia.org/wiki/Citation

      """

  describe 'sha1()', ->
    it 'should return the sha1 of the object record', ->
      tag = new CitationTag( targetType, targetSha1, citationText )
      tag.sha1().should.equal 'd115f73df5dffab5af976180972e3fe7d0f5f104'

  describe 'data()', ->
    it 'should return the tag data as a plain object', ->
      tag1 = fixtures.validCitationTag()
      tag2 = new Tag tag1.data()
      should.ok tag1.equals tag2

describe 'CommentaryTag', ->

  targetType = 'argument'
  targetSha1 = '1a1a1a1a1a1a1a1a000000000000000000000000'
  commentaryText = 'The commentary analysis, up to a few paragraphs...'

  describe 'new CommentaryTag( targetType, targetSha1, commentaryText )', ->
    it 'should create a new commentary tag instance', ->
      commentaryTag = new CommentaryTag( targetType, targetSha1, commentaryText )
      commentaryTag.should.be.an.instanceOf CommentaryTag
      commentaryTag.should.be.an.instanceOf Tag
      commentaryTag.tagType.should.equal 'commentary'
      commentaryTag.targetType.should.equal 'argument'
      commentaryTag.targetSha1.should.equal '1a1a1a1a1a1a1a1a000000000000000000000000'
      commentaryTag.commentaryText.should.equal 'The commentary analysis, up to a few paragraphs...'
      commentaryTag.validate().should.equal true

  describe 'new CommentaryTag( options )', ->
    it 'should create a new commentary tag instance', ->
      tag1 = fixtures.validCommentaryTag()
      options = tag1.data()
      tag2 = new CommentaryTag( options )
      should.ok tag1.equals tag2

  describe 'validate()', ->
    it 'should return false unless targetType is argument', ->
      commentaryTag = new CommentaryTag( 'proposition', targetSha1, commentaryText )
      commentaryTag.validate().should.equal false
      commentaryTag.validationError.message.should.equal "Commentary target type must be 'argument'."

  describe 'objectRecord()', ->
    it 'should return a commentary tag object record', ->
      tag = new CommentaryTag( targetType, targetSha1, commentaryText )
      record = tag.objectRecord()
      record.should.equal """
        tag

        tag_type commentary
        target argument 1a1a1a1a1a1a1a1a000000000000000000000000
        commentary_text The commentary analysis, up to a few paragraphs...

      """

  describe 'sha1()', ->
    it 'should return the sha1 of the object record', ->
      tag = new CommentaryTag( targetType, targetSha1, commentaryText )
      tag.sha1().should.equal 'bf753c448ecc31b1f0f20639f2eb9951cc191be1'

  describe 'data()', ->
    it 'should return the tag data as a plain object', ->
      tag1 = fixtures.validCommentaryTag()
      tag2 = new Tag tag1.data()
      should.ok tag1.equals tag2
