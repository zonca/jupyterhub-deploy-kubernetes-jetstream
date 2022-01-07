.PHONY: list

list:
	@LC_ALL=C $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

reserved_volumes:
	openstack volume list | grep reserve

reserved_attachments:
	cinder attachment-list | grep reserve

delete_attachments:
	cinder attachment-delete $(i)

set_volume_available:
	openstack volume set --state available $(i)
