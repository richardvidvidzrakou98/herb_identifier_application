# ml_model/urls.py
from django.urls import path
from .views import classify_herb, get_search_history

urlpatterns = [
    path('classify-herb/', classify_herb, name='classify_herb'),
    path('get-search-history/', get_search_history, name='get_search_history'),
]
