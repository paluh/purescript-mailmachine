# purescript-mailmachine

Trivial `paluh/mailmachine` PureScript client.

## Usage

If you have `mailmachine` up and running all you need to do is to push `Mailmachine.Mail` record into it by using `send` function.

Something like this should work:

```purescript
module Main where

import Prelude

import Data.Array.NonEmpty (singleton) as NonEmptyArray
import Data.MediaType.Common (textHTML, textPlain)
import Database.Redis (Config, defaultConfig) as Redis
import Effect (Effect)
import Effect.Aff (launchAff_)
import Mailmachine (send) as Mailmachine
import Node.Buffer.Immutable (fromString) as Immutable
import Node.Encoding (Encoding(UTF8))
import Text.Email.Parser (EmailAddress(..))

redisConfig ∷ Redis.Config
redisConfig = Redis.defaultConfig { port = 8888 }

main :: Effect Unit
main = launchAff_ do
  let
    -- | Redis label for a given mailmachine queue
    mailQueue = "mailmachine-dev"
    encode s = Immutable.fromString s UTF8

  Mailmachine.send { redisConfig, mailQueue }
    { alternatives: [{ content: encode "Z poważaniem<br />Zespół spamthewholeworld.expert", mime: textHTML }]
    , attachments:
      [ { content: encode "File content"
        , fileName: "test.txt"
        , mime: textPlain
        }
      ]
    , body: "Z poważaniem,\nZespół spamthewholeworld.expert"
    , fromEmail: EmailAddress
      { localPart: "evil", domainPart: "spamthewholeworld.expert" }
    , recipients: NonEmptyArray.singleton $ EmailAddress
      { localPart: "poor", domainPart: "idontlikespam.com" }
    , subject: "Świeżutki SPAM!"
    }
```
