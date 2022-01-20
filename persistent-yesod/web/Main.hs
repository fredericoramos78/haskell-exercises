{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE FlexibleInstances     #-}

module MainWeb where
  
import Yesod
import Database.Persist.Postgresql as S
import Control.Monad.Logger (runStderrLoggingT)
import Control.Monad.Trans.Resource (runResourceT)

import InitDB
import WebApp

import Models.AppConfig
import Models.WeeklySummary


instance Yesod WebApp



-- First string parameter must match data time defined above
mkYesod "WebApp" [parseRoutes|
/ HomeR GET
/config ConfigListR GET 
/summary WeeklySummaryR GET 
|]

-- remember that `Handler` is a type alias for `HandlerFor WebApp` 
instance HasWebApp (HandlerFor WebApp) where 
  getWebApp = getYesod

getHomeR :: Handler Html
getHomeR = redirect ConfigListR

getConfigListR :: Handler Value
getConfigListR = loadAppConfig >>= returnJson

getWeeklySummaryR :: Handler Value  
getWeeklySummaryR = readWeeklySummary >>= returnJson  
  
main :: IO ()
main = do
  pool <- runStderrLoggingT $ S.createPostgresqlPool "postgresql://lunch:pass123@localhost:5432/lunchdb" 1
  runResourceT $ runSqlPool (runMigration migrateAll) pool
  warp 3000 $ WebApp pool 


