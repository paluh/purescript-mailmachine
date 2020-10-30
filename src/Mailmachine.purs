module Mailmachine where

import Prelude

import Data.Array (fromFoldable) as Array
import Data.Array.NonEmpty (NonEmptyArray)
import Data.MediaType (MediaType)
import Data.Newtype (unwrap)
import Database.Redis (Connection) as Redis
import Database.Redis.Hotqueue (Hotqueue, hotqueueJson)
import Effect.Aff (Aff)
import Node.Buffer.Immutable (ImmutableBuffer)
import Node.Buffer.Immutable (toString) as Immutable
import Node.Encoding (Encoding(Base64))
import Text.Email.Parser (EmailAddress)
import Text.Email.Parser (toString) as Email

type Mail =
  { alternatives ∷ Array
    { content ∷ ImmutableBuffer
    , mime ∷ MediaType
    }
  , attachments ∷ Array
    { content ∷ ImmutableBuffer
    , fileName ∷ String
    , mime ∷ MediaType
    }
  , body ∷ String
  , fromEmail ∷ EmailAddress
  , recipients ∷ NonEmptyArray EmailAddress
  , subject ∷ String
  }

-- | Internal format
type MailJson =
  { alternatives ∷ Array (Array String)
  , attachments ∷ Array
    { content ∷ String
    , file_name ∷ String
    , mime ∷ String
    }
  , body ∷ String
  , from_email ∷ String
  , recipients ∷ Array String
  , subject ∷ String
  }

send ∷ { redis ∷ Redis.Connection, mailQueue ∷ String } → Mail → Aff Unit
send { redis: conn, mailQueue } mail = do
    let
      (o ∷ Hotqueue _ _ (MailJson)) = hotqueueJson conn outQueue
    void $ o.put (encodeEmail mail)
  where
    outQueue = "hotqueue:" <> mailQueue
    encodeAttachment a =
      { content: Immutable.toString Base64 a.content
      , file_name: a.fileName
      , mime: unwrap a.mime
      }
    encodeAlternative a = [ Immutable.toString Base64 a.content, unwrap a.mime ]
    encodeEmail m =
      { attachments: map encodeAttachment m.attachments
      , alternatives: map encodeAlternative m.alternatives
      , body: m.body
      , from_email: Email.toString m.fromEmail
      , recipients: map Email.toString <<< Array.fromFoldable $ m.recipients
      , subject: m.subject
      }

