module Mailmachine where

import Prelude

import Database.Redis (Config, defaultConfig, withConnection) as Redis
import Database.Redis.Hotqueue (Hotqueue, hotqueueJson)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Node.Buffer.Immutable (fromString, toString) as Immutable
import Node.Encoding (Encoding(Base64, UTF8))

type Mail =
  { attachments ∷ Array
      { content ∷ String
      , file_name ∷ String
      , mime ∷ String
      }
  , body ∷ String
  , recipients ∷ Array String
  , from_email ∷ String
  , subject ∷ String
  }

send ∷ { redisConfig ∷ Redis.Config, mailQueue ∷ String } → Mail → Aff Unit
send { redisConfig, mailQueue } mail =
  Redis.withConnection redisConfig \conn → do
    let
      -- | Remainings of python hotqueue ;-)
      outQueue = "hotqueue:" <> mailQueue
      (o ∷ Hotqueue _ _ Mail) = hotqueueJson conn outQueue
    void $ o.put mail

