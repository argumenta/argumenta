
User    = require '../../lib/argumenta/user'
Objects = require '../../lib/argumenta/objects'

{Argument, Proposition, Commit, Tags} = Objects
{SupportTag, DisputeTag, CitationTag, CommentaryTag} = Tags

#
# Fixtures contains Argumenta objects and components for tests.
#
class Fixtures

  #### Users ####

  @validUser: () ->
    return new User @validUsername(), @validEmail(), @validPasswordHash()

  uniqueUserCount = 0

  @uniqueUser: () ->
    return new User( "user#{++uniqueUserCount}",
                     "user#{uniqueUserCount}@xyz.com",
                     @validPasswordHash() )

  @validUsername: () ->
    return 'tester'

  @validEmail: () ->
    return 'tester@xyz.com'

  @validPasswordHash: () ->
    return '$2a$10$EdsQm10l4VTDkr4eLvH09.aXtug.QHDxhNnVHY3Jm.RaG6s5msek2'

  #### Arguments ####

  @validArgument: () ->
    return new Argument @validTitle(), @validPremises(), @validConclusion()

  @invalidArgument: () ->
    return new Argument 'invalid-argument', [ '' ], ''

  @validTitle: () ->
    return 'The Argument Title'

  @validPremises: () ->
    return ['The first premise.', 'The second premise.']

  @validConclusion: () ->
    return 'The conclusion'

  #### Propositions ####

  @validProposition: () ->
    return new Proposition @validPropositionText()

  @invalidProposition: () ->
    return new Proposition ''

  uniquePropositionCount = 0

  @uniqueProposition: () ->
    return new Proposition "Unique proposition text number #{++uniquePropositionCount}."

  @validPropositionText: () ->
    return 'The proposition text.'

  #### Commits ####

  @validCommit: () ->
    return new Commit( @validCommitTargetType(), @validCommitTargetSha1(), @validCommitter(),
                       @validCommitDate(), @validCommitParents() )

  @invalidCommit: () ->
    return new Commit( 'bad-type', 'bad-sha1', 'bad-committer', 'bad-date' )

  @validCommitTargetType: () ->
    return 'argument'

  @validCommitTargetSha1: () ->
    return '39cb3925a38f954cf4ca12985f5f948177f6da5e'

  @validCommitter: () ->
    return 'tester'

  @validCommitDate: () ->
    return '1970-01-01T00:00:00Z'

  @validCommitParents: () ->
    return [
      @validCommitParentSha1A(),
      @validCommitParentSha1B()
    ]

  @validCommitParentSha1 =
  @validCommitParentSha1A = () ->
    return '0123456789abcdef000000000000000000000000'

  @validCommitParentSha1B: () ->
    return '1a1a1a1a1a1a1a1a000000000000000000000000'

  #### Tags ####

  @validTag: () ->
    return new SupportTag @validSupportTargetType(), @validTargetSha1(),
                          @validSupportSourceType(), @validSourceSha1()

  @invalidTag: () ->
    return new SupportTag 'bad-type', 'bad-sha1', 'bad-type', 'bad-sha1'

  @validSupportTag: () ->
    return new SupportTag @validSupportTargetType(), @validTargetSha1(),
                          @validSupportSourceType(), @validSourceSha1()

  @validDisputeTag: () ->
    return new DisputeTag @validDisputeTargetType(), @validTargetSha1(),
                          @validDisputeSourceType(), @validSourceSha1()

  @validCitationTag: () ->
    return new CitationTag @validCitationTargetType(), @validTargetSha1(),
                           @validCitationText()

  @validCommentaryTag: () ->
    return new CommentaryTag @validCommentaryTargetType(), @validTargetSha1(),
                             @validCommentaryText()

  @validSupportTargetType =
  @validDisputeTargetType =
  @validCitationTargetType = () ->
    return 'proposition'

  @validSupportSourceType =
  @validDisputeSourceType =
  @validCitationSourceType = () ->
    return 'argument'

  @validCommentaryTargetType: () ->
    return 'argument'

  @validTargetSha1: () ->
    return '0123456789abcdef000000000000000000000000'

  @validSourceSha1: () ->
    return '1a1a1a1a1a1a1a1a000000000000000000000000'

  @validCitationText: () ->
    return 'The citation text, with URL: http://wikipedia.org/wiki/Citation'

  @validCommentaryText: () ->
    return 'The commentary analysis, up to a few paragraphs...'

module.exports = Fixtures
