{dispatch_impl} = require 'libprotocol'
{info, warn, error, debug} = dispatch_impl 'ILogger', 'IHelper'
Spine = require 'spine'

_isNaN = (v) -> v isnt v

named_waits = {}

module.exports =
    protocols:
        definitions:
            IHelper: [
                ['len',     ['array']]
                ['add',     ['vector']]
                ['drop',    ['items_vec', 'cur_item']]
                ['swap',    ['items_vec', 'cur_item']]
                ['inc',     ['val']]
                ['dec',     ['val']]
                ['parseint',['val']]
                ['proxyinfo', ['a']]
                ['->->->',  ['a']]
                ['say',     ['msgs', 'more'], {vargs: true}]
                ['info',    ['msgs', 'more'], {vargs: true}]
                ['warn',    ['msgs', 'more'], {vargs: true}]
                ['error',   ['msgs', 'more'], {vargs: true}]
                ['debug',   ['msgs', 'more'], {vargs: true}]

                ['not',     ['a']]
                ['stop!',   []]
                ['stop?',   ['patrn', 'val']]
                ['wait',    ['timeout'], {async: true}]

                ['named-wait',    ['timeout', 'name'], {async: true}]
                ['cancel-wait',    ['name']]


                ['preventOnEnter', ['event']]

                ['random',  []]

                ['push-to-google', ['vec']]

                ['###',     ['blk', 'args']]
                ['wrap',    ['tpl', 'pattern', 'value']]

                ['true',    []]
                ['false',   []]
                ['the-undefined', []]

                ['spine-fire',    ['event-name']]

            ]

        implementations:
            IHelper: (node) ->
                'spine-fire': (event_name) ->
                    Spine.trigger event_name

                true: -> true

                false: -> false
                
                'the-undefined': -> undefined

                wrap: (t, p, v) -> t.replace p, v

                '###': (block, args) -> args

                'push-to-google': (p) ->
                    debug 'push-to-google', p
                    push_to_google p...

                random: -> Math.random()

                len: (array) -> array.length or 0

                wait: (timeout, cont) ->
                    debug "waiting #{timeout}ms"
                    setTimeout(
                        ->
                            debug "waiting done"
                            cont()

                        timeout
                    )

                'named-wait': (timeout, name, _, cont) ->
                    debug "named-wait", timeout, name
                    named_waits[name] = setTimeout(
                        ->
                            debug debug "named-wait done", timeout, name
                            cont()

                        timeout
                    )

                'cancel-wait': (name) ->
                    if named_waits[name]
                        debug "cancelling named timeout", name
                        (clearTimeout named_waits[name]) 

                not: (a) -> !a

                "stop!": -> null

                "stop?": (p, v) -> if p is v then null else v

                add: (vec) ->
                    vec.reduce (a, b) -> (parseInt a, 10) + (parseInt b, 10)

                drop: (items, item) ->
                    item_is_in_items = if _isNaN item
                        !!(items.filter (i) -> _isNaN i).length
                    else
                        item in items

                    if item_is_in_items then null else item

                swap: ([from, to], item) ->
                    if ((_isNaN item) and (_isNaN from)) or (item is from)
                        to
                    else
                        item

                '->->->': (a) ->
                    debug "[->->->]", a
                    a

                proxyinfo: (a) ->
                    console.log "%c[proxy:@#{node.id}] ", 'background: #222; color: #bada55', "incoming: #{a}, type: #{typeof a}"
                    a

                info: info

                error: error

                warn: warn

                debug: (a...) -> debug a...

                say: info

                inc: (v) -> parseInt(v, 10) + 1

                dec: (v) -> parseInt(v, 10) - 1

                parseint: (v) -> parseInt v

                preventOnEnter: (e) ->
                    if e.keyCode is 13
                        e.preventDefault()
                    e
