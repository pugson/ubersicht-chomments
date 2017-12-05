# Lovingly crafted by Rohan Likhite [rohanlikhite.com]

# Refresh time (default: 3 minutes)
refreshFrequency: '3m'
token: 'YOUR_AUTHORIZATION_TOKEN'

#Body Style
style: """
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol'
  font-size: 16px

  ::-webkit-scrollbar
    // uncomment `display` below if you have scrollbars active 
    // at all times and not just on scroll
    //display: none

  .container
   position: fixed
   width: 20vw
   top: 0
   left: 0
   bottom: 0
   padding-left: 1rem
   display: flex
   flex-direction: column
   font-smoothing: antialiased
   text-align: left
   flex-wrap: nowrap
   text-shadow: 0 0 30px rgba(0,0,0,.35)
   color: #fff
   background: linear-gradient(90deg, rgba(0,0,0,.5) 0%, transparent 100%)
   -webkit-mask-image: -webkit-gradient(linear, left 80%, left bottom, from(#000), to(rgba(0,0,0,0)));

  .talkbox
   position: relative
   display: flex
   flex-shrink: 0

  input
   background-color: HSLA(253, 79%, 60%, .45)
   color: #fff
   font-size: .75rem
   margin-top: 1rem
   margin-bottom: 1rem
   padding: 1em .75em
   border-radius: .35rem
   box-shadow: none
   border: none
   outline: none
   width: 100%
   transition: .25s ease all

  #chomments
   margin-top: -1rem
   position: relative
   padding-top: 2rem
   height: 95vh
   overflow-y: scroll
   -webkit-mask-image: -webkit-gradient(linear, left 5%, left top, from(#000), to(rgba(0,0,0,0)));

  input:focus
    box-shadow: inset 0 0 0 2px #6A48EA
    background-color: HSLA(253, 79%, 60%, .5)

  .chomment
   color: #fff
   margin-bottom: 1rem

  @keyframes showChomment
   from
    transform: translateY(-1rem)
    opacity: 0
   to
    transform: translateX(0)
    opacity: 1

  p
   font-size: .75rem
   line-height: 1.45
   background-color: rgba(255,255,255, .065)
   // optional blur, worsens performance a bit
   // -webkit-backdrop-filter: blur(5px);
   padding: .5em
   margin: 0
   margin-top: .75em
   border-radius: .5em

  .user
   display: flex
   align-items: center

  img
   width: 1.25rem
   margin-right: .5rem
   border-radius: 100%
   background-color: rgba(255,255,255, .1)
  
  h2
   font-size: .875rem
   font-weight: 600
   margin: 0
   line-height: 1

  [type='submit']
   display: none

"""

#Render function
render: -> """
  <div class='container'>
    <form class='talkbox'>
      <input id="textbox" type="text" placeholder="Say something to the hole..." autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" />
      <input type="submit" />
    </form>
    <div id='chomments'>Loading chomments...</div>
  </div>
"""

getChomments: (handleData) ->
  $.ajax
    url: 'https://api.screenhole.net/chomments?page=1'
    success: (data) ->
      handleData data
      return
  return

update: (output, domEl) ->
  getChomments (output) ->
    data = output.chomments
    recentChomments = data.map (chomment) -> """
      <div class='chomment'>
        <div class='user'>
          <img src='https://www.gravatar.com/avatar/#{chomment.user.gravatar_hash}' />
          <h2>#{chomment.user.username}</h2>
        </div>
        <p>#{chomment.message}</p>
      </div> 
      """

    # localStorage.setItem "chomments", recentChomments
    $ '#chomments'
      .html recentChomments

    $ '#chomments'
      .scrollTop 0
    
    return

afterRender: (domEl, token) ->
  postChomment = (self, message) ->
    $.ajax
      url: "https://api.screenhole.net/chomments",
      beforeSend: (xhr) ->
        xhr.setRequestHeader("Authorization", "Bearer " + token + ""); 
      type: 'POST'
      dataType: 'json'
      contentType: 'application/json;charset=UTF-8'
      processData: false
      data: '{"chomment":{"message":"' + message + '"}}'
      success: (data) ->
        update()
      error: ->
        $ '#chomments'
          .html '<h2>Error, mate...</h2>'

  refreshChomments = (self) ->
    self.run "osascript -e 'tell application \"Übersicht\" to refresh widget id \"chomments-widget-index-coffee\"'"
    $ '#chomments'
      .scrollTop 0
    $ '#textbox'
      .val ''

  self = this

  $(domEl).find('form').on 'submit', =>
    postChomment(self, $(domEl).find('#textbox').val())
    refreshChomments(self)