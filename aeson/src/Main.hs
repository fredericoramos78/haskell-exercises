{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module FredExample where

import GHC.Generics
import Data.Aeson
import Data.Text

content = "{\"name\":\"Fred\", \"age\":10}"

data Person = Person {
  name :: Text,
  age :: Int
} deriving (Show, Generic)

instance FromJSON Person where
    parseJSON = withObject "Person" $ \v -> Person
        <$> v .: "name"
        <*> v .: "age"


main :: IO ()
main = putStrLn $ show $ dd

-- decode will fail json content doesn't contains an array
dd :: Either String [Person]
dd = eitherDecode content
