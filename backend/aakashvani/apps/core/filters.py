import django_filters


class CharInFilter(django_filters.BaseInFilter, django_filters.CharFilter):
    pass
