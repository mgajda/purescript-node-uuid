module Node.UUID where

  import Control.Monad.Eff (Eff(), kind Effect)

  import Data.Argonaut.Decode.Class (class DecodeJson)
  import Data.Argonaut.Decode (class DecodeJson, decodeJson)
  import Data.Argonaut.Encode (class EncodeJson, encodeJson)
  import Data.Either (Either(..))
  import Data.Foreign (readString)
  import Data.Maybe
  import Data.Semigroup ((<>))

  import Prelude (class Ord, class Eq, class Show, (#), ($), (==), (<$>), (>>>), (>>=), show, compare,
                  bind)

  foreign import data UUID    :: Type
  foreign import data UUIDEff :: Effect

  foreign import uuid :: {}
  foreign import showuuid :: UUID -> String
  foreign import v1 :: forall eff. Eff (uuid :: UUIDEff | eff) UUID
  foreign import v4 :: forall eff. Eff (uuid :: UUIDEff | eff) UUID
  foreign import runUUID :: Eff (uuid :: UUIDEff) UUID -> UUID
  foreign import parse :: String -> UUIDBuffer
  foreign import unparse :: UUIDBuffer -> UUID

  type UUIDBuffer = Array Number

  instance eqUUID :: Eq UUID where
    eq ident ident' = showuuid ident == showuuid ident'

  instance ordUUID :: Ord UUID where
    compare ident ident' = compare (showuuid ident) (showuuid ident')

  instance showUUID :: Show UUID where
    show ident = showuuid ident

  readUUID u = (\u' -> parse u' # unparse) <$> readString u

  instance decodeJsonUUID :: DecodeJson UUID where
    decodeJson json = do
      maybeUUID <- decodeJson json
      case maybeUUID of
        Left  e -> Left $ "UUID: " <> e
        Right r -> Right $ unparse $ parse r

  instance encodeJsonUUID :: EncodeJson UUID where
    encodeJson uuid = encodeJson $ show uuid
