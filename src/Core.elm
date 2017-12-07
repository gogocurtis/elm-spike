module Core exposing (Model, update, view, init, subscriptions, location2messages, delta2url)

import Debug as D exposing (log)
import RouteUrl as Routing
import Navigation
import Dict
import Msg exposing (Msg(..))
import Layout
import SignIn exposing (ExternalMsg)
import Session
import Firebase.DB
import Customers
import Html exposing (Html)


type alias EmptyModel =
    {}


type alias Model =
    { customersModel : Customers.Model
    , ordersModel : EmptyModel
    , inventoryModel : EmptyModel
    , signInModel : SignIn.Model
    , dbModel : Firebase.DB.Model
    , session : Session.Session
    }


initModel : Model
initModel =
    { customersModel = Customers.initModel
    , ordersModel = EmptyModel
    , inventoryModel = EmptyModel
    , signInModel = SignIn.initModel
    , dbModel = Firebase.DB.initModel
    , session = Session.init
    }



--
-- Init establishes the basic data structure.
--


init : ( Model, Cmd Msg )
init =
    let
        c =
            D.log "function" "init"
    in
        ( initModel
        , Cmd.none
        )



-- Update is a triggered by a Msg which represents
-- a particular side-effect generated by an actor
--


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        a =
            D.log "model" model

        b =
            D.log "msg" msg

        c =
            D.log "update" "update"
    in
        case msg of
            SelectPage idx ->
                ( { model
                    | session = (Session.setPageIndex model.session idx)
                  }
                , Cmd.none
                )

            SignInPage msg ->
                let
                    ( ( signInModel, cmd ), externalMsg ) =
                        (SignIn.update msg model.signInModel)

                    newModel =
                        case externalMsg of
                            SignIn.EstablishSession firebaseModel ->
                                { model | session = Session.fromFirebaseAuth firebaseModel }

                            SignIn.NoOp ->
                                { model | signInModel = signInModel }
                in
                    ( newModel, Cmd.map SignInPage cmd )

            CustomersPage msg ->
                let
                    next =
                        (Customers.update msg model.customersModel)

                    customersModel =
                        (Tuple.first next)

                    cmd =
                        Cmd.map CustomersPage <| (Tuple.second next)
                in
                    ( { model | customersModel = customersModel }, cmd )

            EmptyPage msg ->
                ( model, Cmd.none )

            FirebaseDBPage msg ->
                let
                    next =
                        (Firebase.DB.update msg model.dbModel)

                    dbModel =
                        (Tuple.first next)

                    cmd =
                        Cmd.map FirebaseDBPage <| (Tuple.second next)
                in
                    ( { model | dbModel = dbModel }, cmd )


view : Model -> Html Msg
view model =
    Layout.view model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map SignInPage (SignIn.subscriptions model.signInModel)
        , Sub.map CustomersPage (Customers.subscriptions model.customersModel)
        , Sub.map FirebaseDBPage (Firebase.DB.subscriptions model.dbModel)
        ]


delta2url : Model -> Model -> Maybe Routing.UrlChange
delta2url model1 model2 =
    if model1.session.pageIndex /= model2.session.pageIndex then
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
