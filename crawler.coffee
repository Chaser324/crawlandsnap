#==============================================================================
# CONFIGURATION
#==============================================================================

SITE_URL = 'http://www.site.com/'

VIEWPORT_WIDTH = 1600
VIEWPORT_HEIGHT = 950

FOLLOW_ANCHORS = false

# Page will not be crawled if url contains one of these strings
URL_NO_FILTER = [
]

URL_FILTER = [
]

# Page will only be captured if it contains one or more of these strings
# TEXT_FILTER = [
# ]


# TEXT_NO_FILTER = [
# ]

#==============================================================================
# VARIABLES
#==============================================================================

visitedUrls = []
pendingUrls = []
hostname = ''

#==============================================================================
# REQUIRE
#==============================================================================

casper.options.viewportSize =
    width: VIEWPORT_WIDTH
    height: VIEWPORT_HEIGHT
# casper.options.pageSettings.loadPlugins = false

utils = require('utils')
helpers = require('./helpers')

#==============================================================================
# FUNCTIONS
#==============================================================================

pageAction = (url) ->
    pageContent = casper.getHTML('body')

    if TEXT_FILTER? 
        filterfound = false
        for filterString in TEXT_FILTER
            if pageContent.indexOf(filterString) > -1
                filterfound = true
                break
        if !filterfound
            return
    if TEXT_NO_FILTER?
        filterfound = false
        for filterString in TEXT_NO_FILTER
            if pageContent.indexOf(filterString) > -1
                filterfound = true
                break
        if filterfound
            return

    filename = url

    filename = filename.replace('http://', '')
    filename = filename.replace('https://', '')

    if filename.charAt(filename.length - 1) is '/'
        filename = filename.slice(0,-1)

    filename = 'output/' + filename + '.png'

    casper.captureSelector filename, 'body'

isLocal = (url) ->
    retval = true
    if url.indexOf('http://') is -1 and url.indexOf('https://') is -1
        retval = false

    if url.indexOf(hostname) is -1 or url.indexOf(hostname) > 8
        retval = false

    return retval

crawl = (url) ->
    visitedUrls.push url

    casper.open(url).then ->
        status = @status().currentHTTPStatus
        statusStyle = { fg: '', bold: true }
        statusStyle.fg = switch status
            when 200 then 'green'
            when 404 then 'red'
            else 'magenta'

        @echo @colorizer.format(status, statusStyle) + ' ' + url

        if status is 200
            pageAction url

        links = @evaluate ->
            links = []

            for linkElement in __utils__.findAll('a')
                links.push linkElement.getAttribute('href')

            return links

        baseUrl = @getGlobal('location').origin
        for link in links
            if link.charAt(0) is '?'
                newUrl = @getGlobal('location').href
                if newUrl.indexOf '?' > -1
                    newUrl = newUrl.slice 0, newUrl.lastIndexOf '?'
                newUrl = newUrl + link
            else
                newUrl = helpers.absoluteUri baseUrl, link

            if !FOLLOW_ANCHORS and newUrl.indexOf('#') > -1
                newUrl = newUrl.substring 0, newUrl.lastIndexOf '#'

            if URL_FILTER?
                testfound = false
                for test in URL_FILTER
                    if newUrl.indexOf(test) > -1
                        testfound = true
                        break
                if !testfound
                    continue

            if URL_NO_FILTER?
                testfound = false
                for test in URL_NO_FILTER
                    if newUrl.indexOf(test) > -1
                        testfound = true
                        break
                if testfound
                    continue

            if pendingUrls.indexOf(newUrl) is -1 and visitedUrls.indexOf(newUrl) is -1 and isLocal(newUrl)
                # @echo @colorizer.format('-> Pushed ' + newUrl + ' onto the stack', { fg: 'magenta' })
                pendingUrls.push newUrl

        if pendingUrls.length > 0
            nextUrl = pendingUrls.shift()
            # @echo @colorizer.format('<- Popped ' + newUrl + ' from the stack', { fg: 'blue' })
            crawl nextUrl


#==============================================================================
# MAIN SCRIPT
#==============================================================================

casper.start SITE_URL, ->
    hostname = @getGlobal('location').hostname
    crawl SITE_URL

casper.run()
