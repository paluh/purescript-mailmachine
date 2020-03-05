# purescript-mailmachine

Trivial `paluh/mailmachine` PureScript client.

## Usage

If you have `mailmachine` up and running all you need is to push mail record into the appropriate redis `queue`. Something like this should work:

```purescript
module Main where

import Prelude

import Database.Redis (Config, defaultConfig) as Redis
import Effect (Effect)
import Effect.Aff (launchAff_)
import Mailmachine (send) as Mailmachine
import Node.Buffer.Immutable (fromString, toString) as Immutable
import Node.Encoding (Encoding(Base64, UTF8))

redisConfig ∷ Redis.Config
redisConfig = Redis.defaultConfig { port = 6379 }

main :: Effect Unit
main = launchAff_ do
  let
    mailQueue = "mails"

  Mailmachine.send
    { redisConfig, mailQueue }
    { attachments: [
      { file_name: "test.txt"
      -- | A bit convoluted example of utf8 text file which is base64 encoded and send as attachment
      , content: Immutable.toString Base64 (Immutable.fromString "File content" UTF8)
      , mime: "text/plain"
      }]
    , body: "Hello from Purescript"
    , from_email: "pidgin@example.com"
    , recipients: ["recipient@example.com"]
    , subject: "Hello from Purescript!"
    }


```
