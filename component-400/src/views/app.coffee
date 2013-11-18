mediator = require '../modules/mediator'
View     = require '../modules/view'

HeaderView     = require './header'
DuplicatesView = require './duplicates'
NoMatchesView  = require './nomatches'
SummaryView    = require './summary'
HeaderView     = require './header'
TooltipView    = require './tooltip'

class AppView extends View

    autoRender: yes

    events:
        'mouseover .help': 'toggleTooltip'
        'mouseout  .help': 'toggleTooltip'

    render: ->
        # Render the header.
        @el.append (new HeaderView({ 'collection': @collection })).render().el

        { data, dict } = @collection

        # Render the duplicates?
        @el.append((view = new DuplicatesView({
            collection
        })).render().el) if collection = data.matches.DUPLICATE

        # Adjust the table.
        do view?.adjust

        # Summary overview?
        @el.append((new SummaryView({
            'collection': data.matches
            dict
        })).render().el)

        @

    # Toggle a tooltip.
    toggleTooltip: (ev) ->
        switch ev.type
            when 'mouseover'
                id = (target = $(ev.target)).data('id')
                @views.push view = new TooltipView({ 'model': { id } })
                target.append view.render().el
            
            when 'mouseout'
                # Only tooltips are in the list.
                ( do view.dispose for view in @views )

module.exports = AppView