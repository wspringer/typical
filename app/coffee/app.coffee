app = angular.module 'when', []

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

app.controller 'MainCtrl', ($scope) ->

  extractOffset = (moment) ->
    offset = /^(([a-z]+)|([0-9]+)) (week|day|year)(s)? (before|after) (.*)$/.exec moment
    if offset?
      [__, __, text, number, period, __, relative, timestamp] = offset
      console.info offset
      date = Date.create timestamp
      factor = if relative == 'before' then -1 else 1
      units = factor * (if text? then namedNumbers[text] else parseInt(number) || 0)
      console.info units
      switch period
        when 'year' then date.addYears units
        when 'week' then date.addWeeks units
        when 'day' then date.addDays units
    else null

  extractDate = (moment) ->
    Date.create moment

  $scope.moment = 'today'
  $scope.date = () ->
    result = extractOffset($scope.moment) || extractDate($scope.moment)
    if result? and result.isValid()
      result.long()
    else
      'undefined'

