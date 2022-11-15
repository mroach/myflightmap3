
priv/static/images/airlines/logos/%:
	curl -SsL -o $(@) https://www.gstatic.com/flights/airline_logos/70px/dark/$(@F)

assets/images/heroicons/%:
	curl -SsfL -o $(@) https://raw.githubusercontent.com/tailwindlabs/heroicons/master/optimized/24/outline/$(@F)
