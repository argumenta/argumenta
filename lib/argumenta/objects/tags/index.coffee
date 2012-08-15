Tag           = require '../tag'
SupportTag    = require './support_tag'
DisputeTag    = require './dispute_tag'
CitationTag   = require './citation_tag'
CommentaryTag = require './commentary_tag'

# Tags contains a list of classes - one for each tag type.
#
# The tag inheritance hierarchy:
#
#     Tag
#     |-- SupportTag
#     |-- DisputeTag
#     |-- CitationTag
#     `-- CommentaryTag
#
class Tags

  @Tag: Tag
  @SupportTag: SupportTag
  @DisputeTag: DisputeTag
  @CitationTag: CitationTag
  @CommentaryTag: CommentaryTag

module.exports = Tags
