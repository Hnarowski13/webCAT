from django import forms
from django.forms import ModelForm
# from django.contrib.auth import authenticate
# from django.utils.translation import ugettext_lazy as _
# from django.conf import settings

# import string

# from django.contrib.auth import authenticate
# from django.contrib.auth.forms import AuthenticationForm

from .models import *

class AddCategoryForm(forms.ModelForm):

    name = forms.CharField()
    description = forms.CharField(required=False)

    class Meta:
        model = Category
        fields = ['name','description']

class AddSubCategoryForm(forms.ModelForm):

    name = forms.CharField()
    description = forms.CharField(required=False)

    class Meta:
        model = SubCategory
        fields = ['name','description']


class EditCategoryForm(forms.Form):
    category_name = forms.CharField()
    category_description = forms.CharField()	