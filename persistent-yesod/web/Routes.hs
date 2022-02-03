{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE FlexibleInstances     #-}

-- Usually called Foundation with all instances
module Routes where 

import Yesod 
import WebApp

instance Yesod WebApp

-- First string parameter must match data time defined above
mkYesodData "WebApp" $(parseRoutesFile "config/routes")

-- remember that `Handler` is a type alias for `HandlerFor WebApp` 
instance HasWebApp (HandlerFor WebApp) where 
  getWebApp = getYesod
