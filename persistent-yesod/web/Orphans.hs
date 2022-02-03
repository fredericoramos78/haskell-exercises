{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
module Orphans where

import Yesod.Core.Content
import Data.Aeson

-- This is an alternative to have all JSON **response** types implementing `ToJSON` 
--   and also have the handlers type as `Handler (JSONResponse a)` (meaning and additional `JSONResonse <$>` fmap)
--
-- It creates a polymorphic instance for the `ToTypedContent` and `ToContent` type classes, and as long as those
--   reponse types have a `ToJSON` instance, they will fit in these and no extra code is needed. This is also nice
--   since it turns the handler result types less verbose (=doesn't expose they are returning JSON payloads). Which
--   might be desirable if we have a mix of return types for all our endpoints! 
instance {-# OVERLAPPABLE #-} ToJSON a => ToTypedContent a where
  toTypedContent = TypedContent typeJson . toContent

instance {-# OVERLAPPABLE #-} ToJSON a => ToContent a where
  toContent = toContent . encode

