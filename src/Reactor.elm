module Reactor exposing (update, view, init, subscriptions, location2messages, delta2url)

import Html exposing (div, text, a, h1, img, map)
import Html.Attributes exposing (href, style, src, alt)
import Html.Events as E
import Debug as D exposing (log)
import RouteUrl as Routing
import Navigation
import Dict
import Array
import Empty as EmptyView
import Customers as CustomersView
import Ribbon exposing (defaultConfig)
import Css
import Css.Colors
import Html.Styled as St
import Html.Styled.Attributes as Sa exposing (css)
import Layout

import Msg exposing(Msg(..))
import SignIn as SignInView


type alias CustomerModel =
    { list : List String
    }


type alias EmptyModel =
    {}


type alias AccountModel =
    { name : String}


type alias Model =
    { customersModel : CustomerModel
    , ordersModel : EmptyModel
    , inventoryModel : EmptyModel
    , selectedPageIndex : Int
    , accountModel : Maybe AccountModel
    }


model =
    { customersModel = CustomerModel [ "joe", "sue", "betty", "wilma", "frank" ]
    , ordersModel = EmptyModel
    , inventoryModel = EmptyModel
    , selectedPageIndex = 0
    , accountModel = Nothing
    }



--
-- Init establishes the basic data structure.
--


init =
    let
        c =
            D.log "function" "init"
    in
        ( model
        , Cmd.none
        )



-- Update is a triggered by a Msg which represents
-- a particular side-effect generated by an actor
--


update msg model =
    let
        a =
            D.log "model" model

        b =
            D.log "msg" msg

        c =
            D.log "update"
    in
    case msg of
        SelectPage idx ->
            case model.accountModel of
                Just a -> 
                    ( { model | selectedPageIndex = idx }, Cmd.none )
                Nothing ->
                    (model, Cmd.none)
        SignInPage msg ->
            ( {model | accountModel = Just ({name = "Joe"}),
                   selectedPageIndex = 1
              } , Cmd.none )
        CustomersPage msg ->
            ( model, Cmd.none )

        EmptyPage msg ->
            ( model, Cmd.none )

        SignOut ->
            ({model| accountModel = Nothing,
                     selectedPageIndex = 0
             }, Cmd.none)


view model =
    Layout.view model


subscriptions model =
    Sub.none


delta2url : Model -> Model -> Maybe Routing.UrlChange
delta2url model1 model2 =
    if model1.selectedPageIndex /= model2.selectedPageIndex then
        { entry = Routing.NewEntry
        , url = Layout.urlOf model2
        }
            |> Just
    else
        Nothing


location2messages : Navigation.Location -> List Msg
location2messages location =
    let
        a =
            D.log "location2messages -> location" location
    in
        [ case String.dropLeft 1 location.hash of
            "" ->
                SelectPage 0

            x ->
                Dict.get x Layout.urlTabs
                    |> Maybe.withDefault -1
                    |> SelectPage
        ]
