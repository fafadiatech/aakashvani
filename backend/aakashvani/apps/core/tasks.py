class AppTask:
    autoretry_for = (Exception,)
    retry_kwargs = {"max_retries": 3}
