# tweetbrew

[![Build Status](https://travis-ci.org/xu-cheng/tweetbrew.svg?branch=master)](https://travis-ci.org/xu-cheng/tweetbrew)

A twitter bot generates tweet about new formulae in [Homebrew](http://brew.sh).

## Example

See the live action in [@brew_sci](https://twitter.com/brew_sci). A tweet would be like:

> New formula fermikit in Homebrew/science https://github.com/lh3/fermikit  http://arxiv.org/abs/1504.06574  #bioinformatics

For new formulae in [Homebrew/science](https://github.com/Homebrew/homebrew-science), the tweet will contains tags and DOI references if they are available.

## Configuration

### For Homebrew official Taps

The bot is running on [Heroku](https://www.heroku.com). To enable this bot for new tap:

* Goto the repository settings > Webhooks & Services > Add webhook.
  * Add payload URL(`https://tweetbrew.herokuapp.com/payload`) and secret.
  * Choose "Just the push event" in "Which events would you like to trigger this webhook?".
* Edit `app/tweetbrew/config.rb`, add an entry to `TWITTER_ACCOUNT_MAP`.
* (optional) To enable new twitter account:
  * Goto https://apps.twitter.com to register a new app. And generates four tokens. i.e. `consumer_key`, `consumer_secret`, `access_token` and `access_token_secret`.
  * Goto heroic app settings page, add the four tokens acquired above in "Config Variables" panel. The corresponding variable key should be `TWITTER_CONSUMER_KEY_{ACCOUNT_NAME}`, `TWITTER_CONSUMER_SEC_{ACCOUNT_NAME}`, `TWITTER_ACCESS_TOKEN_{ACCOUNT_NAME}` and `
TWITTER_ACCESS_TOKEN_SEC_{ACCOUNT_NAME}`. Where the `{ACCOUNT_NAME}` should be the twitter account name in capital form.

### For unofficial Taps

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)
