express = require('express')
async = require('async')
request = require('request')
router = express.Router()

### GET home page. ###

router.get '/', (req, res, next) ->
  res.render 'index', title: 'Express'
  return


router.get '/auth', (req, res) ->
  key = process.env.pocket1
  codeUrl = 'https://getpocket.com/v3/oauth/request'
  redirect_uri = process.env.pocket_url
  form = {
    'consumer_key':key
    'redirect_uri':redirect_uri
  }
  op = {
    url:codeUrl
    form:form
  }

  async.auto
    getCode:(cb) ->
      request.post op, (err, response, body) ->
        return saveErr op.url, 1, {err:err} if err

        console.log "body1 ==>", body
        if response.statusCode is 200
          code = body.split('=')[1]
          cb(null, code)

        else
#          saveErr op.url, 2, {err:body}
          req.session.error = "连接Pocket出错"
          return res.redirect('/')


    directUrl:['getCode', (cb, result) ->
      code = result.getCode
      req.session.code = code
      url = "https://getpocket.com/auth/authorize?request_token=#{code}&redirect_uri=#{redirect_uri}"
      return res.redirect url

    ]


router.get '/oauth_callback', (req, res) ->
  url = 'https://getpocket.com/v3/oauth/authorize'
  key = process.env.pocket1
  username = ''
  token = ''
  form = {
    consumer_key:key
    code:req.session.code
    headers:{
      'Content-Type': 'application/json; charset=UTF-8'
    }
  }

  op = {
    url:url
    form:form
  }
  request.post op, (err, response, body) ->
    return saveErr op.url, 1, {err:err} if err

    if response.statusCode is 200
      console.log "body =>", body
      infoArr = body.split('&')
      token = infoArr[0].split('=')[1]
      username = infoArr[1].split('=')[1]
      res.send "okok"

    else
      req.session.error = "获取pocket token 出错"
      console.log token
      return res.redirect('/')


router.get '/test', (req, res) ->
  url = 'https://getpocket.com/v3/get'
  form = {
    consumer_key:process.env.pocket1
    access_token:''
    count:'2'
    detailType:'complete'
  }
  op = {
    url:url
    form:form
  }
  request.post op, (err, response, body) ->
    return console.log err if err

    console.log body





module.exports = router