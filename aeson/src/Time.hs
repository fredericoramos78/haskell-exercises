{-# LANGUAGE OverloadedStrings #-}
module Time where

import Control.Monad.Fail (fail)
import Data.Aeson
import Data.Time
import Data.Text

newtype EvolveUTCDatetime = EvolveUTCDatetime UTCTime deriving (Show, Eq)

instance FromJSON EvolveUTCDatetime where
  parseJSON = withText "EvolveUTCDatetime" $ \t ->
    case parseTimeM True defaultTimeLocale "%FT%T%Q" (unpack t) of
      Just d -> pure $ EvolveUTCDatetime d
      _ -> fail "could not parse Evolve datetime"


data Person = Person {
  dob :: UTCTime
} deriving (Show)

instance FromJSON Person where
    parseJSON = withObject "Person" $ \v -> Person
        <$> v .: "dob"

main :: IO ()
main = putStrLn $ show $ dd

content = "{\"dob\":\"2022-02-24T15:51:53\"}"
-- decode will fail json content doesn't contains an array
dd :: Either String Person
dd = eitherDecode content
