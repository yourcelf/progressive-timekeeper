#= require 'jquery'
#= require 'jquery.sparkline'
#= require 'underscore'
#= require 'underscore-autoescape'
#= require 'backbone'
#= require 'backbone-localstorage'

MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

formatTime = (now) ->
    [h, m] = [now.getHours(), now.getMinutes()]
    time = "#{if h > 12 then h - 12 else h}:#{if m < 10 then "0#{m}" else m} " +
           "#{if h > 12 then "PM" else "AM"}"
    return time

class Category extends Backbone.Model
  toggleActive: =>
    if @get("active") then @stop() else @start()

  start: =>
    @set active: true
    if @started?
      return
    @lastStart = new Date().getTime()
    @lastElapsed = @get("elapsed") or 0
    @started = setInterval =>
      @_updateElapsed()
    , 1000

  stop: =>
    @set active: false
    if @started?
      clearInterval @started
      @started = null
    series = @get("series") or []
    series.push([@lastStart, new Date().getTime()])
    @set series: series
    @_updateElapsed()
    @lastStart = @lastElapsed = null

  _updateElapsed: =>
    @set elapsed: @lastElapsed + (new Date().getTime() - @lastStart)
    @save()

class CategoryList extends Backbone.Collection
  model: Category
  localStorage: new Store("progressive-timekeeper")

class ClockView extends Backbone.View
  render: =>
    go = =>
      now = new Date()
      time = formatTime(now)
      $(@el).html(time)
    go()
    if @goer?
      clearInterval @goer
    @goer = setInterval go, 1000
    this

  stop: =>
    clearInterval @goer

class CategoryView extends Backbone.View
  template: _.template $("#showCategory").html()
  events:
    'click a.activate': 'toggleActive'

  initialize: (model) ->
    @model = model
    @model.on 'change', @render

  toggleActive: (event) ->
    @model.toggleActive()
    @render()
    return false

  render: =>
    elapsed = @model.get('elapsed') or 0
    seconds = Math.round(elapsed / 1000) % 60
    seconds = if seconds < 10 then "0" + seconds else seconds
    minutes = Math.floor(elapsed / 1000 / 60)

    $(@el).addClass "buttonrow"
    $(@el).html @template
      category: @model.get('category')
      seconds: seconds
      minutes: minutes
      active: @model.get('active')
    this

class CategoryEdit extends Backbone.View
  template: _.template $("#editCategory").html()

  initialize: (model) =>
    @model = model
  
  render: =>
    $(@el).html @template
      category: @model.get "category"
    this

  save: =>
    cat = $("input[name=category]", @el).val()
    @model.set
      category: $("input[name=category]", @el).val()
    return false

class Settings extends Backbone.View
  template: _.template $("#settings").html()
  max_entries: 8
  events:
    'click a.save': 'save'
    'click .cancel': 'cancel'

  initialize: (categoryList) ->
    @cats = categoryList

  render: =>
    $(@el).html @template()
    @editViews = []
    for i in [0...@max_entries]
      if @cats.at i
        model = @cats.at i
      else
        model = new Category
      view = new CategoryEdit(model)
      $(".categorylist", @el).append view.render().el
      @editViews.push view
    this

  save: =>
    for i in [0...@cats.length]
      @cats.shift()
    for view in @editViews
      view.save()
      if view.model.get("category")
        @cats.add view.model
        view.model.save()
    app.navigate "", trigger: true
    return false

  cancel: =>
    app.navigate "", trigger: true
    return false

class TimeKeeper extends Backbone.View
  template: _.template $("#timekeeper").html()
  events:
    'click .settings': 'settings'
    'click .graph': 'graph'
    'click .about': 'about'
    'click .reset': 'reset'

  initialize: (categoryList) ->
    @cats = categoryList
    @cats.bind "change", @updateStart

  render: =>
    $(@el).html @template()
    @clock.stop() if @clock? # avoid leaking intervals
    @clock = new ClockView()
    $(".clock", @el).html @clock.render().el
    for cat in @cats.models
      cv = new CategoryView(cat)
      $(".categorylist", @el).append(cv.el)
      cv.render()
    @updateStart()
    this

  updateStart: =>
    min = 1000000000000000000000
    found = false
    for cat in @cats.models
      if cat.get("series")?.length > 0
        min = Math.min(min, cat.get("series")[0][0])
        found = true
    date = new Date(min)
    if found
      $(".meeting-start", @el).html(
        "Start: #{MONTHS[date.getMonth()]} #{date.getDate()}, #{formatTime(date)}"
      )
    else
      $(".meeting-start", @el).html("&nbsp;")

  settings: (event) ->
    app.navigate "settings", trigger: true
    return false

  reset: (event) ->
    if confirm("Reset timetables?")
      for cat in @cats.models
        cat.save
          elapsed: 0
          series: []
    return false

  graph: (event) ->
    app.navigate 'graph', trigger: true
    return false

  about: (event) ->
    app.navigate 'about', trigger: true
    return false


class Graph extends Backbone.View
  template: _.template $("#graph").html()
  barWidth: 4
  barSpacing: 0
  events:
    'click a.back': 'back'
    'click .export': 'exportJSON'

  initialize: (categoryList) ->
    @cats = categoryList

  render: =>
    $(@el).html @template()
    #
    # Get maximum and minimum times, and percentages.
    #
    min = 10000000000000000
    max = 0
    cat_totals = {}
    total_total = 0
    for cat in @cats.models
      c = cat.get("category")
      cat_totals[c] = 0
      for turn in cat.get("series") or []
        min = Math.min(turn[0], min)
        max = Math.max(turn[1], max)
        cat_totals[c] += turn[1] - turn[0]
        total_total += cat_totals[c]
    #
    # Draw labels
    #
    $(".labels", @el).html("")
    for cat in @cats.models
      c = cat.get("category")
      percent = parseInt(cat_totals[c] / total_total * 100)
      $(".labels", @el).append($("<div/>").html "#{c} (#{percent}%)")

    if max > 0
      #
      # Graph ranges
      #
      range = max - min
      $(".lines", @el).width $(".lines", @el).parent().width() - $(".labels", @el).width()
      width = $(".lines", @el).width()
      pixelBins = width / (@barWidth + @barSpacing)
      timeBin = range / pixelBins
      maxProportion = 0
      for cat in @cats.models
        time = min
        catVals = []
        while time < max
          proportion = 0
          for turn in cat.get("series") or []
            proportion += Math.max(
              0, Math.min(time + timeBin, turn[1]) - Math.max(time, turn[0])
            )
          catVals.push(proportion)
          maxProportion = Math.max(proportion, maxProportion)
          time += timeBin
        div = $("<div/>")
        $(".lines", @el).append(div)
        div.sparkline catVals,
          type: 'bar'
          chartRangeMin: 0
          chartRangeMax: maxProportion
          barWidth: @barWidth
          barSpacing: @barSpacing
          barColor: "#090"
    this

  back: =>
    app.navigate "", trigger: true
    return false

  exportJSON: (event) ->
    app.navigate 'export.json', trigger: true
    return false

class Export extends Backbone.View
  template: _.template $("#export").html()
  events:
    'click a.back': 'back'

  initialize: (categoryList) ->
    @cats = categoryList

  render: =>
    $(@el).html @template exportJSON: JSON.stringify(@cats)
    this

  back: =>
    app.navigate "", trigger: true
    return false

class About extends Backbone.View
  template: _.template $("#about").html()
  events:
    'click a.back': 'back'

  render: =>
    $(@el).html @template()
    this

  back: =>
    app.navigate "", trigger: true
    return false

class App extends Backbone.Router
  routes:
    "settings":      "settings"
    "graph":         "graph"
    "export.json":   "exportJSON"
    "about":         "about"
    "":              "timekeep"
  defaults: ['Female', 'Male', 'White', 'Person of color']

  initialize: ->
    @cats = new CategoryList
    @cats.fetch()
    if @cats.length == 0
      for d in @defaults
        cat = new Category(category: d)
        @cats.add cat
        cat.save()

  timekeep: =>
    $("#app").html new TimeKeeper(@cats).render().el

  settings: =>
    $("#app").html new Settings(@cats).render().el

  graph: =>
    graph = new Graph(@cats)
    $("#app").html graph.el
    graph.render()

  exportJSON: =>
    $("#app").html new Export(@cats).render().el

  about: =>
    $("#app").html new About().render().el

app = new App()
Backbone.history.start()
