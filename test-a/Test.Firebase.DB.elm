module Test.Utils.RandomUser exposing (main)
import Test exposing (describe, test)
import Test.Runner.Html exposing (run)


import Utils.RandomUser

import Expect
-- Check out http://package.elm-lang.org/packages/elm-community/elm-test/latest to learn more about testing in Elm!
main =
    run <| all

all: Test.Test
all =
    describe "Firebase Id Sanitize"
        [
         test "sanitizeId" <|
            \_ ->
                Expect.equal (Utils.RandomUser.sanitizeId ".0-10.10") "-0-10-10"
        ]
