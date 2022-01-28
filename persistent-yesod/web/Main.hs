{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}

module MainWeb where
  
import Yesod
import Database.Persist.Postgresql as S
import Control.Monad.Logger (runStderrLoggingT)
import Control.Monad.Trans.Resource (runResourceT)

import InitDB
import WebApp
import Routes
import Handlers

import Models.AppConfig
import Models.WeeklySummary


---- CHALLENGE #1: move handlers into their own module!
-- Context:
--  `mkYesod` is a combination of `mkYesodData` and `mkYesodDispatch`. The former is how our routes & handlers are connected to Yesod machinery. The latter handles the link
--    between URLs and our handler functions.
-- Details: 
-- * https://stackoverflow.com/questions/56722924/split-yesod-app-source-code-into-multiple-source-files
-- * https://stackoverflow.com/questions/65887147/where-does-the-resourcesapp-come-from-in-yesod
-- * https://www.schoolofhaskell.com/school/advanced-haskell/building-a-file-hosting-service-in-yesod/part%202
mkYesodDispatch "WebApp" resourcesWebApp

---- CHALLENGE #2: move routes into a yesod file
-- Not much to say. We replace `[parseRoutes|...]` inline code with a function call which single param is a file. The contents of the file
--   is basically the same as we had before in the enclosing `[...]`. That code change was all in the `Routes` module.

---- CHALLENGE #3: entities into their own file
---- CHALLENGE #4: Handlers returning more specific types (not the generic `Value`)  
  
main :: IO ()
main = do
  pool <- runStderrLoggingT $ S.createPostgresqlPool "postgresql://lunch:pass123@localhost:5432/lunchdb" 1
  runResourceT $ runSqlPool (runMigration migrateAll) pool
  warp 3000 $ WebApp pool 


