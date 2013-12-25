results  = require './results'
ejs      = require './ejs'

Document = require '../models/document'

# State of the application.
State = can.Map.extend

    # Loading.
    loading: ->
        state
        .attr('text', 'Loading results &hellip;')
        .attr('class', 'info')
        # Clear results.
        do results.attr('docs').destroy
        results.attr('total', 0)

    # We have results.
    hasResults: (total, docs) ->
        state.attr('class', 'info')
        # How many?
        if total > ejs.attr('size')
            state.attr('text', "Top results out of #{total} matches")
        else
            if total is 1
                state.attr('text', '1 Result')
            else
                state.attr('text', "#{total} Results")

        # Destroy previous results.
        do results.attr('docs').destroy

        # Save the results.
        results
        .attr('total', total)
        .attr('docs', new Document.List(docs))
    
    # We have no results.
    noResults: ->
        state
        .attr('text', 'No results found')
        .attr('class', 'info')
        
        # Clear results.
        do results.attr('docs').destroy
        results.attr('total', 0)

    # Something bad.
    error: (err) ->
        text = 'Error'
        switch
            when _.isString err
                text = err
            when _.isObject err and err.message
                text = err.message

        state
        .attr('text', text)
        .attr('class', 'alert')
        
        # Clear results.
        do results.attr('docs').destroy
        results.attr('total', 0)

# New global state instance.
module.exports = state = new State
    'text': 'Search ready'
    'class': 'info'