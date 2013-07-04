class SomeModel extends Backbone.Model


class SomeCollection extends Backbone.Collection
    model: SomeModel


class SomeView extends Backbone.View

    initialize: ->
        @state = new Backbone.Model(numberOfRenders: 0)
        @collection.on('add', @render, @)

    render: ->
        # count renders
        n = @state.get('numberOfRenders')
        @state.set(numberOfRenders: n + 1)

        # create HTML
        html = '<ul>'
        @collection.each (x) ->
            html += "<li>#{x.get('word')}</li>"
        # for x in @collection
        #     html += "<li>#{x.get('word')}</li>"
        html += '<ul>'

        # update DOM
        $(@el).html(html)
        @


class SomeViewWithRaf extends SomeView

    render: ->
        if not @waitingForRender
            @waitingForRender = yes
            window.requestAnimationFrame =>
                @waitingForRender = no
                super
        @


class NumberOfRendersView extends Backbone.View

    initialize: ({@watchedState}) ->
        @watchedState.on('change:numberOfRenders', @render, @)

    render: ->
        n = @watchedState.get('numberOfRenders')
        $(@el).html("<p>Number of renders: #{n}</p>")
        @


$ ->
    # create collection
    collection = new SomeCollection()

    for [selector, View] in [
        ['#js-without-raf', SomeView]
        ['#js-with-raf', SomeViewWithRaf]
    ]
        # create views
        mainView = new View(collection: collection)
        countView = new NumberOfRendersView(watchedState: mainView.state)

        # put views on the page
        $(selector).
            html(countView.render().el).
            append(mainView.render().el)

    # populate collection
    for word in ['foo', 'bar', 'baz', 'qux', 'quux']
        collection.add(new SomeModel(word: word))

    # add object after a delay
    msg = 'delayed one second'
    setTimeout((-> collection.add(new SomeModel(word: msg))), 1000)
