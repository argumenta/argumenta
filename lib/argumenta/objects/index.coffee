
Argument    = require './argument'
Proposition = require './proposition'
Commit      = require './commit'
Tags        = require './tags'

#
# Objects contains classes for each type of Argumenta object.
#
class Objects

  @Argument:      Argument
  @Proposition:   Proposition
  @Commit:        Commit
  @Tag:           Tags.Tag

  @Tags:          Tags

  @SupportTag:    Tags.SupportTag
  @DisputeTag:    Tags.DisputeTag
  @CitationTag:   Tags.CitationTag
  @CommentaryTag: Tags.CommentaryTag

module.exports = Objects
