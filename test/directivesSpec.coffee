'use strict'

describe 'Piwik Directives', ->
  elm = scope = win = {}

  shift_until = (arr, str) ->
    ret = arr.shift() until ret?[0] == str
    return ret

  beforeEach ->
    module 'piwik'

    inject ($rootScope, $compile, $window) ->
      elm = angular.element '''<div>
        <ngp-piwik
          ngp-set-js-url="https://piwik.personal.com/piwik.js"
          ngp-set-tracker-url="https://piwik.personal.com/piwik.php"
          ngp-set-site-id="42"
          ngp-set-domains="www.personal.com,demo.personal.com">
        </ngp-piwik>
      </div>'''
      scope = $rootScope
      $window['_paq'] = undefined
      win = $window
      $compile(elm)(scope)
      scope.$digest()
      return
    return


  it 'should create script element', ->
    scr_elm = elm.find('script')
    expect(scr_elm.length).toBe(1)
    expect(scr_elm.attr('src')).toEqual("https://piwik.personal.com/piwik.js")

  it 'should create call queue', ->
    expect(win['_paq']).toBeDefined()
    expect(win['_paq'].length).toEqual(7)

  it 'should place trackerUrl on call queue before trackPageView', ->
    cmd = shift_until win['_paq'], 'setTrackerUrl'
    expect(cmd.length).toEqual(2)
    expect(cmd[0]).toEqual('setTrackerUrl')
    expect(cmd[1]).toEqual('https://piwik.personal.com/piwik.php')

    cmd = shift_until win['_paq'], 'trackPageView'
    expect(cmd[0]).toEqual('trackPageView')

  it 'should place siteid on call queue before trackPageView', ->
    cmd = shift_until win['_paq'], 'setSiteId'
    expect(cmd.length).toEqual(2)
    expect(cmd[0]).toEqual('setSiteId')
    expect(cmd[1]).toEqual('42')

    cmd = shift_until win['_paq'], 'trackPageView'
    expect(cmd[0]).toEqual('trackPageView')

  it 'should recognize and process arrays', ->
    cmd = win['_paq'].shift() until cmd?[0] == 'setDomains'
    expect(cmd[1].length).toBe(2)
    expect(cmd[1][0]).toEqual('www.personal.com')
    expect(cmd[1][1]).toEqual('demo.personal.com')