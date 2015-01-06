_ = require 'lodash'
deep = require('object-path')

# @pluck (array|object|string)
# Works as a replacement for 'pick' too.
_.pluck = (items, pluck) ->
  unless _.isObject(items) and pluck
    return items

  pluckMany = (item) -> # {oldKey: newKey}
    if _.isString pluck
      return deep.get item, pluck
    newObj = {}
    _.each pluck, (copyKey, setKey) ->
      newKey = if _.isString setKey then setKey else copyKey
      deep.set newObj, newKey, deep.get(item, copyKey)
    return newObj

  # Collection of objects.
  if _.isArray items
    items = _.map items, pluckMany
  # Single object.
  else if _.isObject items
    items = pluckMany items

  return items

_.move = (item, oldPath, newPath) ->
  deep.set item, newPath, deep.get(item, oldPath, newPath)
  deep.del item, oldPath
  item

_.rename = (item, rename) ->
  unless _.isObject(rename) and _.isObject(item)
    return item
  _.each rename, (newKey, oldKey) =>
    item = @move item, oldKey, newKey
    return
  return item

# Remove unwanted fields from an object. Dangerous.
_.clean = (item) ->
  unless _.isObject item
    return item
  _.each item, (value, id) ->
    if _.isString(value) and _.isEmpty(value)
      delete item[id]
    else if value == null
      delete item[id]
    else if _.isArray(value) and _.isEmpty(_.compact(value))
      delete item[id]
    else if _.isObject(value) and not(value instanceof Date) and _.isEmpty(value)
      delete item[id]
    return
  return item

_.without = (items, without) ->
  if _.isString without
    without = [without]
  if _.isArray(items)
    items = _.map items, (item) =>
      return @without item, without
  else if _.isObject items
    _.each without, (rmPath) ->
      deep.del items, rmPath
  return items

module.exports = _
