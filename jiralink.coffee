# Description
#   Listen to messages for Jira IDs. When Jira ticket IDs are sent in messages
#   hubot will construct a full URL to the Jira ticket and post the link.
#
# Dependencies:
#   None
#
# Configuration:
#   JIRA_SUBDOMAIN
#   JIRA_USERNAME
#   JIRA_PASS
#
# Commands:
#   <projectId-issueId> - constructs a jira link to the ticket matching `jira id`
#
# Notes:
#   None
#
# Author:
#   stickel

module.exports = (robot) ->
  # Regex to check `matches` against for IDs
  idRegex = /(^|\s)((\w+[^\d])-(\d+(?!\w)))/ig
  # Avoid repetition from these user names
  excludeFromResponses = ['Automated Process', 'JIRA', 'GitHub']
  # Array of rooms to exclude
  excludeRooms = ['devops', 'devops_console']
  user = process.env.JIRA_USERNAME
  pass = process.env.JIRA_PASS
  apiBaseUrl = "https://#{process.env.JIRA_SUBDOMAIN}.atlassian.net/rest/api/2/issue/"
  auth = 'Basic ' + new Buffer(user + ':' + pass).toString('base64')

  showTicket = (msg, ticket, cb) ->
    msg.http(apiBaseUrl + ticket)
      .headers(Authorization: auth, Accept: 'application/json')
      .get() (err, res, body) ->
        cb JSON.parse(body)

  robot.hear idRegex, (msg) ->
    # ignore messages from the exclusion list
    return if msg.message.user.name in excludeFromResponses
    # ignore messages in certain rooms
    return if msg.message.room in excludeRooms
    ticketUrl = "https://#{process.env.JIRA_SUBDOMAIN}.atlassian.net/browse/"

    for matched in msg.match
      ticket = (matched.match /(\w+-[0-9]+)/)[0]
      showTicket msg, ticket, (text) ->
        msg.send ticketUrl + text.key + ': ' + text.fields.summary
