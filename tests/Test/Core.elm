module Test.Core exposing (..)

import Core
import Debug
import Expect
import Msg exposing (Msg(..))
import Session exposing (SessionStatus)
import SignIn
import Test exposing (..)


-- import Test.Runner.Html exposing (run)
-- Check out http://package.elm-lang.org/packages/elm-community/elm-test/latest to learn more about testing in Elm!
-- main =
--     run <| all


b msg =
    Debug.log "B called" msg


all : Test.Test
all =
    describe "Core"
        [ describe "update"
            [ describe "Msg (SelectPage Int)"
                [ test "without a session.account the model will not change" <|
                    \_ ->
                        let
                            initialModel =
                                Core.init |> Tuple.first

                            model =
                                Tuple.first <| Core.update (SelectPage 1) initialModel
                        in
                        Expect.equal initialModel model
                , test "with a valid session.account the model will change selectedPageIndex" <|
                    \_ ->
                        let
                            initialModel =
                                Core.init |> Tuple.first

                            session =
                                Session.init

                            signedInSession =
                                { session | status = Session.Valid, account = Just <| Session.Account "name" }

                            model =
                                Tuple.first <| Core.update (SelectPage 1) { initialModel | session = signedInSession }
                        in
                        Expect.equal 1 model.session.pageIndex
                ]
            ]
        ]
