{-# LANGUAGE ConstraintKinds       #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE IncoherentInstances   #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE UndecidableInstances  #-}
{-# LANGUAGE ViewPatterns          #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
-----------------------------------------------------------------------------
-- |
-- Module      : Data.Array.Accelerate.Linear.V1
-- Copyright   : 2014 Edward Kmett, Charles Durham,
--               2015 Trevor L. McDonell
-- License     : BSD-style (see the file LICENSE)
--
-- Maintainer  : Edward Kmett <ekmett@gmail.com>
-- Stability   : experimental
-- Portability : non-portable
--
-- 1-D Vectors
----------------------------------------------------------------------------

module Data.Array.Accelerate.Linear.V1 (

  V1(..), R1(..), ex,

) where

import Data.Array.Accelerate                    as A
import Data.Array.Accelerate.Smart
import Data.Array.Accelerate.Product
import Data.Array.Accelerate.Array.Sugar

import Data.Array.Accelerate.Linear.Lift
import Data.Array.Accelerate.Linear.Metric
import Data.Array.Accelerate.Linear.Type
import Data.Array.Accelerate.Linear.Vector

import Control.Lens
import Linear.V1                                ( V1(..) )
import qualified Linear.V1                      as L
import Prelude                                  as P


-- | A space that has at least 1 basis vector '_x'.
--
class L.R1 t => R1 t where
  -- |
  -- >>> V1 2 ^._x
  -- 2
  --
  -- >>> V1 2 & _x .~ 3
  -- V1 3
  --
  _x :: (Elt a, Box t a) => Lens' (Exp (t a)) (Exp a)
  _x = liftLens (L._x :: Lens' (t (Exp a)) (Exp a))


ex :: R1 t => E t
ex = E _x


-- Instances
-- ---------

instance Metric V1
instance Additive V1
instance R1 V1

type instance EltRepr (V1 a) = EltRepr a

instance Elt a => Elt (V1 a) where
  eltType _ = eltType (undefined :: a)
  toElt = V1 . toElt
  fromElt (V1 a) = fromElt a

instance cst a => IsProduct cst (V1 a) where
  type ProdRepr (V1 a) = ((), a)
  fromProd _ (V1 x) = ((), x)
  toProd _ ((), x) = V1 x
  prod _ _ = ProdRsnoc ProdRunit

instance (Lift Exp a, Elt (Plain a)) => Lift Exp (V1 a) where
  type Plain (V1 a) = V1 (Plain a)
  lift (V1 x) = Exp . Tuple $ NilTup `SnocTup` lift x

instance Elt a => Unlift Exp (V1 (Exp a)) where
  unlift t = V1 $ Exp $ ZeroTupIdx `Prj` t

instance A.Num a => P.Num (Exp (V1 a)) where
  (+)             = lift2 ((+) :: V1 (Exp a) -> V1 (Exp a) -> V1 (Exp a))
  (-)             = lift2 ((-) :: V1 (Exp a) -> V1 (Exp a) -> V1 (Exp a))
  (*)             = lift2 ((*) :: V1 (Exp a) -> V1 (Exp a) -> V1 (Exp a))
  negate          = lift1 (negate :: V1 (Exp a) -> V1 (Exp a))
  signum          = lift1 (signum :: V1 (Exp a) -> V1 (Exp a))
  abs             = lift1 (signum :: V1 (Exp a) -> V1 (Exp a))
  fromInteger x   = lift (fromInteger x :: V1 (Exp a))

instance A.Floating a => P.Fractional (Exp (V1 a)) where
  (/)             = lift2 ((/) :: V1 (Exp a) -> V1 (Exp a) -> V1 (Exp a))
  recip           = lift1 (recip :: V1 (Exp a) -> V1 (Exp a))
  fromRational x  = lift (fromRational x :: V1 (Exp a))

instance A.Floating a => P.Floating (Exp (V1 a)) where
  pi              = lift (pi :: V1 (Exp a))
  log             = lift1 (log :: V1 (Exp a) -> V1 (Exp a))
  exp             = lift1 (exp :: V1 (Exp a) -> V1 (Exp a))
  sin             = lift1 (sin :: V1 (Exp a) -> V1 (Exp a))
  cos             = lift1 (cos :: V1 (Exp a) -> V1 (Exp a))
  tan             = lift1 (tan :: V1 (Exp a) -> V1 (Exp a))
  sinh            = lift1 (sinh :: V1 (Exp a) -> V1 (Exp a))
  cosh            = lift1 (cosh :: V1 (Exp a) -> V1 (Exp a))
  tanh            = lift1 (tanh :: V1 (Exp a) -> V1 (Exp a))
  asin            = lift1 (asin :: V1 (Exp a) -> V1 (Exp a))
  acos            = lift1 (acos :: V1 (Exp a) -> V1 (Exp a))
  atan            = lift1 (atan :: V1 (Exp a) -> V1 (Exp a))
  asinh           = lift1 (asinh :: V1 (Exp a) -> V1 (Exp a))
  acosh           = lift1 (acosh :: V1 (Exp a) -> V1 (Exp a))
  atanh           = lift1 (atanh :: V1 (Exp a) -> V1 (Exp a))

instance (Elt a, Elt b) => Each (Exp (V1 a)) (Exp (V1 b)) (Exp a) (Exp b) where
  each = liftLens (each :: Traversal (V1 (Exp a)) (V1 (Exp b)) (Exp a) (Exp b))
