--
-- This snippet shows the behaviour around the "monomorphic restriction" (more https://wiki.haskell.org/Monomorphism_restriction and 
--    https://www.haskell.org/onlinereport/haskell2010/haskellch4.html#x10-930004.5.5)
--
-- In essence it's a safeguard on the compiler that specializes function definitions/types whenever no type signature is specified to it. 
-- 
-- It explains why on both `testLet` and `testWhere` we need to specify the type for `flatAndAppy`. If we don't, we get a compile 
--   error on the second invocation of `flatAndApply` saying something like `expected type (MyStruct -> Maybe Int)` but found `(MyStruct -> Maybe Bool)`.
--
module MonomorphicRestriction where 

import Control.Applicative ( Applicative(liftA2), Alternative((<|>)) )

data MyStruct = MyStruct 
    { 
      myIntField :: Maybe Int
    , myBoolField :: Maybe Bool
    }

flatAndApplyOnEither :: Enum a => Maybe MyStruct -> Maybe MyStruct -> (MyStruct -> Maybe a) -> Maybe a
flatAndApplyOnEither m1 m2 f = fAppliedToM1 <|> fAppliedToM2
    where fAppliedToM1 = m1 >>= f
          fAppliedToM2 = m2 >>= f


testLet :: Maybe (Int, Bool)
testLet = do
    let m1 = Just $ MyStruct (Just 10) Nothing
        m2 = Just $ MyStruct Nothing (Just True)
        flatAndApply :: Enum a => (MyStruct -> Maybe a) -> Maybe a
        flatAndApply = flatAndApplyOnEither m1 m2
    b <- flatAndApply myBoolField
    i <- flatAndApply myIntField
    return (i, b)


testWhere :: Maybe (Int, Bool)
testWhere = liftA2 (,) i b 
    where m1 = Just $ MyStruct (Just 10) Nothing
          m2 = Just $ MyStruct Nothing (Just True)
          flatAndApply :: Enum a => (MyStruct -> Maybe a) -> Maybe a
          flatAndApply = flatAndApplyOnEither m1 m2
          b = flatAndApply myBoolField
          i = flatAndApply myIntField
