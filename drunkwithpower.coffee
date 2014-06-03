# Description
#   Listens to messages where people ask if anyone is drunk with power and
#   and responds with an image
#
# Dependencies:
#   None
#
# Configuration:
#   none
#
# Commands:
#   'is <name> drunk with power' - responds with a gif
#
# Notes:
#   None
#
# Author:
#   stickel

module.exports = (robot) ->

  responses = [
    'http://i.imgur.com/EpOns1C.gif'
  ]

  robot.hear /is (.*) drunk with power/i, (msg) ->
    msg.send msg.random responses
