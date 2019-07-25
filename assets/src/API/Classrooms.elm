module API.Classrooms exposing (ClassroomForm, classrooms, editClassroom, encodeClassroomForm, formFromClassroom)

import API exposing (APIData, APIResult)
import API.Endpoint as Endpoint
import Http exposing (jsonBody)
import Json.Decode as Decode
import Json.Encode as Encode
import Session exposing (Session)
import Time as Time
import Types exposing (..)



-- Classrooms


classrooms : Session -> (APIData (List Classroom) -> msg) -> Cmd msg
classrooms session toMsg =
    API.getRemote Endpoint.classrooms (Session.credential session) (Decode.list classroomDecoder) toMsg


type alias ClassroomForm =
    { courseCode : String, name : String, description : String }


formFromClassroom : Classroom -> ClassroomForm
formFromClassroom classroom =
    { courseCode = classroom.courseCode
    , name = classroom.name
    , description = Maybe.withDefault "" classroom.description
    }


encodeClassroomForm : ClassroomForm -> Encode.Value
encodeClassroomForm form =
    Encode.object
        [ ( "course_code", Encode.string form.courseCode )
        , ( "name", Encode.string form.name )
        , ( "description", Encode.string form.description )
        ]


editClassroom : Session -> ClassroomId -> ClassroomForm -> (APIData Classroom -> msg) -> Cmd msg
editClassroom session id form toMsg =
    API.putRemote (Endpoint.classroom id) (Session.credential session) (jsonBody <| encodeClassroomForm form) classroomDecoder toMsg