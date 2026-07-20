from rest_framework import serializers

from apps.aakashvani.models import User, UserZoneScope
from apps.core.serializers import TimestampedSerializer


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()


class UserSerializer(TimestampedSerializer):
    zone_scope = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            "id",
            "email",
            "name",
            "role",
            "is_active",
            "created_at",
            "updated_at",
            "zone_scope",
            "password",
        ]
        extra_kwargs = {"password": {"write_only": True, "required": False}}

    def get_zone_scope(self, obj):
        return list(UserZoneScope.objects.filter(user=obj).values_list("zone_id", flat=True))

    def create(self, validated_data):
        password = validated_data.pop("password", None)
        user = User(**validated_data)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save()
        return user
