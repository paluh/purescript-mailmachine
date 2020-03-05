# purescript-mailmachine

Trivial `paluh/mailmachine` PureScript client.

## Usage

If you have `mailmachine` up and running all you need is to push mail record into appropriate redis `queue`. Something like this should work:

```purescript
module Main where

import Prelude

import Database.Redis (Config, defaultConfig, withConnection) as Redis
import Database.Redis.Hotqueue (Hotqueue, hotqueueJson)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Mailmachine (Mail) as Mailmachine
import Node.Buffer.Immutable (fromString, toString) as Immutable
import Node.Encoding (Encoding(Base64, UTF8))

redisPort ∷ Int
redisPort = 6379

redisConfig ∷ Redis.Config
redisConfig = Redis.defaultConfig { port = redisPort }

main :: Effect Unit
main = launchAff_ do
  let outQueue = "hotqueue:mails"

  Redis.withConnection redisConfig \conn → do
    let
      -- | A bit convoluted example of utf8 text file which is base64 encoded and send as attachment
      content = Immutable.toString Base64 (Immutable.fromString "File content encoded in utf8..." UTF8)
      (o ∷ Hotqueue _ _ Mailmachine.Mail) = hotqueueJson conn outQueue
      m =
        { attachments: [{ file_name: "attachment.txt", content, mime: "text/plain" }]
        , body: "Hello from Purescript"
        , from_email: "pidgin@spam-the-world.com"
        , recipients: ["recipient@example.com"]
        , subject: "Hello from Purescript!"
        }
    void $ o.put m
```
