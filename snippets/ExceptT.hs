module ExceptT where 

import Control.Monad.IO.Class
import Control.Monad.Trans.Except 
import Text.Read

helper1 :: (MonadIO m) => ExceptT String m Int 
helper1 = ExceptT $ do 
  l <- liftIO getLine
  pure $ Right $ read l

helper2 :: (MonadIO m) => ExceptT String m ()
helper2 = ExceptT $ liftIO $ do
  print "ERRRRR"
  pure $ Left "Ops"


{-
This example demonstrates `EitherT`'s hability to short-circuit. The `"HERE"` print won't show unless we remove 
 `helper2` from this do block (or replace it with another `helper1` call)
-}
example1 :: ExceptT String IO Int
example1 = do
  r <- helper1
  y <- helper2
  x <- ExceptT $ liftIO $ do 
    print "HERE"
    pure $ Right ()
  pure r

-- This shows we can still handle the final result of an `EitherT` computation even if it short-circuits. 
example2 = do
  e <- runExceptT example1 
  case e of
    Right x -> print $ "success: " ++ show x 
    Left y -> print $ "ops! " ++ y 


