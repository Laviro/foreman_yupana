# ForemanRhCloud

*Introdction here*

## Installation

See [How_to_Install_a_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Plugin)
for how to install Foreman plugins

## Usage

*Usage here*

### In Satellite

#### Inventory upload

In UI: Configure -> Inventory Upload -> Generate and upload report 

From command-line:

    # generate and upload report for all organizations
    /usr/sbin/foreman-rake rh_cloud_inventory:report:generate_upload

    # generate and upload report for specific organization
    export organization_id=1
    /usr/sbin/foreman-rake rh_cloud_inventory:report:generate_upload

    # generate report for specific organization (don't upload)
    export organization_id=1
    export target=/var/lib/foreman/red_hat_inventory/generated_reports/
    /usr/sbin/foreman-rake rh_cloud_inventory:report:generate

    # upload previously generated report (needs to be named 'report_for_#{organization_id}.tar.gz')
    export organization_id=1
    export target=/var/lib/foreman/red_hat_inventory/generated_reports/
    /usr/sbin/foreman-rake rh_cloud_inventory:report:upload

#### Fetch hosts remediation data

In UI: Configure -> Insights -> Sync now

From command-line:

    /usr/sbin/foreman-rake rh_cloud_insights:sync

#### Synchronize inventory status

In UI: Configure -> Inventory Upload -> Sync all inventory status

From command-line:

    # all organizations
    /usr/sbin/foreman-rake rh_cloud_inventory:sync

    # specific organization with id 1
    export organization_id=1
    /usr/sbin/foreman-rake rh_cloud_inventory:sync

## TODO

*Todo list here*

## Design

### Endpoints

| purpose                       | url    | ENV setting for the **bold** part
| ------------------------------| -------| -----------
| Inventory uploads             | **https://cert.cloud.redhat.com/api/ingress/v1/upload**    | SATELLITE_INVENTORY_UPLOAD_URL
| Query inventory hosts list    | **https://cloud.redhat.com** /api/inventory/v1/hosts?tags=  | SATELLITE_RH_CLOUD_URL
| Query insights hits           | **https://cloud.redhat.com** /api/insights/v1/export/hits/  | SATELLITE_RH_CLOUD_URL
| Query insights rules          | **https://cloud.redhat.com** /api/insights/v1/rule/?impacting=true&rule_status=enabled&has_playbook=true&limit=&offset=  | SATELLITE_RH_CLOUD_URL
| Query insights resolutions    | **https://cloud.redhat.com** /api/remediations/v1/resolutions| SATELLITE_RH_CLOUD_URL
| Forward insights-client `/static` requests    | **https://cloud.redhat.com** /api/static    | SATELLITE_RH_CLOUD_URL
| Forward insights-client legacy `/platform` requests    | **https://cert.cloud.redhat.com** /api    | SATELLITE_CERT_RH_CLOUD_URL
| Forward insights-client legacy `/redhat_access/r/insights` requests    | **https://cert-api.access.redhat.com** /r/insights    | SATELLITE_LEGACY_INSIGHTS_URL


## Contributing

Fork and send a Pull Request. Thanks!

## Copyright

Copyright (c) 2013 - 2024 - The Foreman Team

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
