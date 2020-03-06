# purescript-mailmachine

Trivial `paluh/mailmachine` PureScript client.

## Usage

If you have `mailmachine` up and running all you need is to push mail record into the appropriate redis `queue`. Something like this should work:

```purescript
module Main where

import Prelude

import Data.MediaType.Common (textHTML, textPlain)
import Database.Redis (Config, defaultConfig) as Redis
import Effect (Effect)
import Effect.Aff (launchAff_)
import Mailmachine (send) as Mailmachine
import Node.Buffer.Immutable (fromString) as Immutable
import Node.Encoding (Encoding(UTF8))

redisConfig ∷ Redis.Config
redisConfig = Redis.defaultConfig { port = 8888 }

main :: Effect Unit
main = launchAff_ do
  let
    mailQueue = "mailmachine-dev"
    encode s = Immutable.fromString s UTF8

  -- Text files and alternatives should be UTF-8 encoded
  -- because mailmachine is doing some trickery to send them
  -- without base64 encoding
  Mailmachine.send { redisConfig, mailQueue }
    { attachments: [
      { file_name: "test.txt"
      , content: encode "File content"
      , mime: textPlain
      }]
    , alternatives: [{ content: encode "<h1>Dzień dobry</h1>", mime: textHTML }]
    , body: "Dzień dobry"
    , from_email: "evil@spamthewholeworld.expert"
    , recipients: ["receipient@example"]
    , subject: "Hello from Purescript!"
    }
```
