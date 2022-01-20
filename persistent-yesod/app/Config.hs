{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedStrings #-}

module Config where

import Data.Time
import Data.Yaml
import Data.Yaml.Config (useEnv, loadYamlSettings)
import Control.Monad.Reader



data AppSettings = AppSettings {
  weekStartsOnMonday :: Bool 
}

-- reading the config file into the settings type
instance FromJSON AppSettings where
  parseJSON = withObject "AppSettings" $ \o -> do
    breakDay <- o .: "week-starts-on-monday"
    pure AppSettings { weekStartsOnMonday = breakDay }


readStartDayOfWeek :: (MonadIO m) => m DayOfWeek
readStartDayOfWeek = do 
  settings <- liftIO $ loadYamlSettings ["config/settings.yaml"] [] useEnv
  let isMonday = weekStartsOnMonday settings
  pure $ if isMonday then Monday else Sunday  
  
  
