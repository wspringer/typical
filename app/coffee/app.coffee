app = angular.module 'when', ['uuid4']

app.config ['$compileProvider', ($compileProvider) ->
  $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|data):/);
]

namedNumbers = {
  'one': 1,
  'two': 2,
  'three': 3,
  'four': 4,
  'five': 5,
  'six': 6,
  'seven': 7,
  'eight': 8,
  'nine': 9,
  'ten': 10,
  'twenty': 20,
  'thirty': 30
}

app.controller 'MainCtrl', ($scope, uuid4) ->

  extractOffset = (moment) ->
    offset = /^(([a-z]+)|([0-9]+))\s(week|day|year)(s)?\s(before|after)\s(.*)$/.exec moment
    if offset?
      [__, __, text, number, period, __, relative, timestamp] = offset
      date = Date.create timestamp
      factor = if relative == 'before' then -1 else 1
      units = factor * (if text? then namedNumbers[text] else parseInt(number) || 0)
      switch period
        when 'year' then date.addYears units
        when 'week' then date.addWeeks units
        when 'day' then date.addDays units
    else null

  extractDate = (moment) ->
    Date.create(moment)

  toIcs = (date) ->
    if date?
      end = Date.create(date).addHours(1)
      desc = 'Get something done'
      format = '{yyyy}{MM}{dd}T{hh}{mm}{ss}'
      """BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//flotsam/when//NONSGML v1.0//EN
CALSCALE:GREGORIAN
BEGIN:VEVENT
DTSTAMP:#{Date.create('now').format format}
DTSTART:#{date.format format}
DTEND:#{end.format format}
DESCRIPTION:#{desc}
UID:#{uuid4.generate()}
SUMMARY:#{desc}
END:VEVENT
END:VCALENDAR"""
    else ''

  $scope.moment = 'today'

  $scope.detected = null

  $scope.$watch 'moment', (newValue) ->
    date = extractOffset(newValue) || extractDate(newValue)
    $scope.detected =
      if date? and date.isValid
        ics = toIcs(date)
        link = 'data:text/calendar;charset=utf8,' + encodeURI(ics)
        {
          'date': date,
          'ics': toIcs(date),
          'link': link
        }
      else null

  return
