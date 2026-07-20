from django.contrib import admin

from apps.aakashvani import models


@admin.register(models.User)
class UserAdmin(admin.ModelAdmin):
    list_display = ("email", "name", "role", "is_active")
    search_fields = ("email", "name")
    list_filter = ("role", "is_active")


admin.site.register(models.UserZoneScope)
admin.site.register(models.Zone)
admin.site.register(models.Device)
admin.site.register(models.DeviceLog)
admin.site.register(models.OTAJob)
admin.site.register(models.Broadcast)
admin.site.register(models.BroadcastZoneTarget)
admin.site.register(models.BroadcastDeviceTarget)
admin.site.register(models.BroadcastAck)
admin.site.register(models.Schedule)
admin.site.register(models.ScheduleZoneTarget)
admin.site.register(models.ScheduleDeviceTarget)
admin.site.register(models.AudioClip)
admin.site.register(models.Voice)
admin.site.register(models.AppSettings)
admin.site.register(models.Trigger)
