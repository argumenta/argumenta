
User       = require '../../lib/argumenta/user'
PublicUser = require '../../lib/argumenta/public_user'
Repo       = require '../../lib/argumenta/repo'
Objects    = require '../../lib/argumenta/objects'

{Argument, Proposition, Commit, Tags} = Objects
{SupportTag, DisputeTag, CitationTag, CommentaryTag} = Tags

#
# Fixtures contains Argumenta objects and components for tests.
#
class Fixtures

  #### Data ####

  @validArgumentData: () ->
    return @validArgument().data()

  @invalidArgumentData: () ->
    return @invalidArgument().data()

  @uniqueArgumentData: () ->
    return @uniqueArgument().data()

  @validUserData: () ->
    return {
      username: @validUsername()
      email: @validEmail()
      password: @validPassword()
      password_hash: @validPasswordHash()
    }

  @invalidUserData: () ->
    return {
      username: ''
      email: ''
      password: ''
      password_hash: ''
    }

  @uniqueUserData: () ->
    user = @uniqueUser()
    return {
      username: user.username
      email: user.email
      password: @validPassword()
      password_hash: @validPasswordHash()
    }

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

  @validPassword: () ->
    return 'tester12'

  @validPasswordHash: () ->
    return '$2a$10$EdsQm10l4VTDkr4eLvH09.aXtug.QHDxhNnVHY3Jm.RaG6s5msek2'

  @invalidUser: () ->
    return new User '', '', ''

  #### Public Users ####

  @validPublicUser: () ->
    return new PublicUser @validUsername()

  uniquePublicUserCount = 0

  @uniquePublicUser: () ->
    return new PublicUser "publicUser#{++uniquePublicUserCount}"

  #### Repos ####

  @validRepoName: () ->
    return 'the-argument-title'

  @validRepo: () ->
    return new Repo @validPublicUser(), @validRepoName(), @validCommit(), @validArgument()

  uniqueRepoCount = 0

  @uniqueRepo: () ->
    return new Repo @validPublicUser(), "unique-reponame-#{++uniqueRepoCount}",
      @validCommit(), @validArgument()

  #### Arguments ####

  @validArgument: () ->
    return new Argument @validTitle(), @validPremises(), @validConclusion()

  uniqueArgumentCount = 0

  @uniqueArgument: () ->
    return new Argument "Title #{++uniqueArgumentCount}",
                        @uniquePremises(), @uniqueConclusion()

  @invalidArgument: () ->
    return new Argument 'invalid-argument', [ '' ], ''

  @validTitle: () ->
    return 'The Argument Title'

  @validPremises: () ->
    return ['The first premise.', 'The second premise.']

  @uniquePremises: () ->
    return [@uniqueProposition().text, @uniqueProposition().text]

  @validConclusion: () ->
    return 'The conclusion'

  @uniqueConclusion: () ->
    return @uniqueProposition().text

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

  @validPropositionMetadata: (prop=@validProposition()) ->
    return {
      sha1: prop.sha1()
      object_type: 'proposition'
      tag_sha1s: {
        support: []
        dispute: []
        citation: []
      }
      tag_counts: {
        support: 0
        dispute: 0
        citation: 0
      }
    }

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

  uniqueCitationCount = 0

  @uniqueCitationTag: () ->
    return new CitationTag @validCitationTargetType(), @validTargetSha1(),
                           "Unique citation no. #{++uniqueCitationCount}"

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
