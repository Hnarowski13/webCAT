from django.conf.urls import url

from classroom import views

urlpatterns = [
    url(r'^$', views.ClassroomView.as_view(), name='classroom-home'),
    url(r'^register_class', views.register_class, name='classroom-register'),
    url(r'^edit_classroom/(?P<pk>\d+)/$', views.edit_classroom, name='classroom-edit'),
    url(r'^edit_rotation', views.AddEditRotation.as_view(), name='classroom-edit-rotation'),
    url(r'^delete_rotation/(?P<pk>\d+)/$', views.DeleteRotation.as_view(), name='classroom-delete-rotation'),
    url(r'^add_student', views.add_student, name='classroom-create-student'),
    url(r'^edit_student/(?P<pk>\d+)/$', views.edit_student, name='classroom-edit-student'),
    url(r'^remove_students/(?P<pk>\d+)/$', views.DeleteAllStudentsView.as_view(), name='classroom-nuke-students'),
    url(r'^add_group', views.add_group, name='classroom-create-group'),
    url(r'^upload/student/$', views.UploadStudentsView.as_view(), name='classroom-upload-students'),
    url(r'^assign/$', views.AssignGroupsView.as_view(), name='classroom-assign-groups'),
    url(r'^assign/(?P<pk>\d+)/$', views.AssignMultipleGroupsView.as_view(), name='classroom-assign-multiple-groups'),
    url(r'^assign_students/(?P<pk>\d+)/$', views.AssignMultipleStudentsView.as_view(),
        name='classroom-assign-multiple-students'),
    url(r'^students/delete/(?P<pk>\d+)/$', views.DeleteStudent.as_view(), name="delete-student"),
    url(r'^groups/delete/(?P<pk>\d+)/$', views.DeleteGroup.as_view(), name="delete-group"),
]
