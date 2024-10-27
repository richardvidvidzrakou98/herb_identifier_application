from django.db import models

# models here.
from django.db import models
from django.contrib.auth.models import User

class HerbIdentification(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)  # Optional: if you want to link the identification to a user
    herb_name = models.CharField(max_length=100)
    description = models.TextField()
    date_identified = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.herb_name

class HerbSearchHistory(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    herb_name = models.CharField(max_length=100)
    medicinal_properties = models.TextField()
    uses = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} searched for {self.herb_name}"