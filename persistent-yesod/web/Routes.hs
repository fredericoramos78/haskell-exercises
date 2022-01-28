{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE FlexibleInstances     #-}

module Routes where 

import Yesod 
import WebApp

instance Yesod WebApp

-- First string parameter must match data time defined above
mkYesodData "WebApp" [parseRoutes|
/ HomeR GET
/config ConfigListR GET 
/summary WeeklySummaryR GET 
|]

-- remember that `Handler` is a type alias for `HandlerFor WebApp` 
instance HasWebApp (HandlerFor WebApp) where 
  getWebApp = getYesod
