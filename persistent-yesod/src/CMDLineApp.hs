{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module CMDLineApp where 
  
import InitDB
import BudgetDB
import LineItemDB
  
import Control.Monad.Reader
import Data.Pool
import Database.Persist.Postgresql as S


newtype Env = Env { envPool :: Pool SqlBackend }
  
newtype AppT a = AppT { unAppT :: ReaderT Env IO a }
  deriving newtype (Functor, Applicative, Monad, MonadReader Env, MonadIO)
  
runAppT :: MonadIO m => AppT a -> Env -> m a
runAppT body env = liftIO $ runReaderT (unAppT body) env

runDB :: ReaderT SqlBackend IO a -> AppT a
runDB body = do
  pool <- asks envPool
  let result = runSqlPool body pool
  liftIO result
  
type SqlPersistT' = ReaderT SqlBackend
type DB' = SqlPersistT' IO  


initMigration :: AppT ()
initMigration = do
  runDB $ do
    runMigration migrateAll
  liftIO $ putStrLn "db migrations executed successfully"

bootstrapDB :: Double -> [LineItem] -> AppT ()
bootstrapDB weeklyBudget lineItems = do
  runDB $ do
    setWeeklyBudget weeklyBudget
    insertNewItems lineItems
  liftIO $ putStrLn "budget initialized"
