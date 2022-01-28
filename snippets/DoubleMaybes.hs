module DoubleMaybes where 
    
data TransactionMeta = TransactionMeta {
    isForce :: Maybe Bool,
    somethingElse :: Int 
}

data Transaction = Transaction {
    meta :: Maybe TransactionMeta,
    something :: Int 
}

f :: Transaction -> Maybe Bool 
f transaction = do
    m <- meta transaction
    isForce m 