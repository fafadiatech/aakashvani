from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import exception_handler


class AakashvaniError(Exception):
    pass


class DeviceOfflineError(AakashvaniError):
    pass


class BroadcastDispatchError(AakashvaniError):
    pass


class QuietHoursActiveError(AakashvaniError):
    pass


def api_exception_handler(exc, context):
    response = exception_handler(exc, context)
    if response is not None:
        return response

    if isinstance(exc, QuietHoursActiveError):
        return Response({"detail": str(exc) or "Quiet hours are active."}, status=status.HTTP_400_BAD_REQUEST)
    if isinstance(exc, DeviceOfflineError):
        return Response({"detail": str(exc) or "Device is offline."}, status=status.HTTP_409_CONFLICT)
    if isinstance(exc, BroadcastDispatchError):
        return Response(
            {"detail": str(exc) or "Failed to dispatch broadcast."},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )
    if isinstance(exc, AakashvaniError):
        return Response({"detail": str(exc) or "Application error."}, status=status.HTTP_400_BAD_REQUEST)

    return None
