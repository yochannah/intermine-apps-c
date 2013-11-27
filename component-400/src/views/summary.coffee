{ _, csv, saveAs } = require '../modules/deps'

mediator   = require '../modules/mediator'
formatter  = require '../modules/formatter'
View       = require '../modules/view'
Table      = require './table'

# Show summary of all but matches and duplicates.
class SummaryView extends View

    autoRender: yes

    template: require '../templates/summary/tabs'

    events:
        'click .button.download': 'download'

    render: ->
        @el.html do @template

        tabs    = @el.find '.tabs'
        content = @el.find '.tabs-content'

        showFirstTab = _.once (reason) -> mediator.trigger 'tab:switch', reason

        for { name, collection, reason } in @options.matches
            # Tab switcher.
            @views.push view = new TabSwitcherView { 'model': { name  }, reason }
            tabs.append view.render().el
            
            # Content in two types of tables.
            Clazz = if reason is 'MATCH' then TabMatchesTableView else TabTableView
            @views.push view = new Clazz({ collection, reason })
            content.append view.render().el

            # Show the first one by default.
            showFirstTab reason

        @

    # Saves the summary into a file.
    download: ->
        columns = null ; rows = []

        adder = (match, input) ->
            [ columns, row ] = formatter.csv match, columns
            rows.push [ input, reason ].concat row

        for { collection, reason } in @options.matches
            for item in collection
                # Many to one relationships.
                if reason is 'MATCH'
                    ( adder(item, input) for input in item.input )
                # One to many relationships.
                else
                    ( adder(match, item.input) for match in item.matches )

        columns = [ 'input', 'reason' ].concat columns

        # Converted to a csv string.
        converted = csv _.map rows, (row) ->
            _.zipObject columns, row
        # Make into a Blob.
        blob = new Blob [ converted ], { 'type': 'text/csv;charset=utf-8' }
        # Save it.
        saveAs blob, 'summary.csv'

# One tab to switch among.
class TabSwitcherView extends View

    template: require '../templates/summary/tab'

    tag: 'dd'

    events:
        'click *': 'onclick'

    constructor: ->
        super

        # Toggle tab?
        mediator.on 'tab:switch', (reason) ->
            @el.toggleClass 'active', @options.reason is reason
        , @

    onclick: ->
        mediator.trigger 'tab:switch', @options.reason

# Content of one tab.
class TabTableView extends Table.OtMTableView

    tag: 'li'

    # Listen to tab switching.
    constructor: ->
        # Toggle content?
        mediator.on 'tab:switch', (reason) ->
            @el.toggleClass 'active', @options.reason is reason
        , @

        @

        super

class TabMatchesTableView extends Table.MtOTableView

    tag: 'li'

    # Listen to tab switching.
    constructor: ->
        # Toggle content?
        mediator.on 'tab:switch', (reason) ->
            @el.toggleClass 'active', @options.reason is reason
        , @

        @

        super

module.exports = SummaryView