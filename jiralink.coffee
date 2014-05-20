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
  idRegex = /(^|\s)(\w+-\d+)(?!\w)/i
  # Avoid repetition from these user names
  excludeFromResponses = ['Automated Process', 'JIRA', 'GitHub']

  robot.hear idRegex, (msg) ->
    # ignore messages from the exclusion list
    return if msg.message.user.name in excludeFromResponses
    apiBaseUrl = "https://#{process.env.JIRA_SUBDOMAIN}.atlassian.net/rest/api/2/issue/"
    ticketUrl = "https://#{process.env.JIRA_SUBDOMAIN}.atlassian.net/browse/"
    user = process.env.JIRA_USERNAME
    pass = process.env.JIRA_PASS
    auth = 'Basic ' + new Buffer(user + ':' + pass).toString('base64')

    # Gather all IDs from `msg.match.input` in case there are multiple
    # IDs in a single message
    matches = msg.match.input.split ' '

    for m in matches
      if m.match idRegex
        # Query the Atlassian API for more info on each ticket
        msg.http(apiBaseUrl + m)
          .headers(Authorization: auth, Accept: 'application/json')
          .get() (err, res, body) ->
            try
              json = JSON.parse(body)
              # HipChat can't accept html messages yet, so send it formatted as:
              # http://domain.atlassian.net/browse/TIK-1234: Title of ticket
              msg.send ticketUrl + json.key + ': ' + json.fields.summary
            catch error
              # There was a problem fetching from the API, send the URL instead
              msg.send ticketUrl + m
