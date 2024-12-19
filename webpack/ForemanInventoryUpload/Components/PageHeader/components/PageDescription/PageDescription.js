import React from 'react';
import { Text } from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';
import { FormattedMessage } from 'react-intl';

export const PageDescription = () => (
  <div id="inventory_page_description">
    <Text>
      {__(
        'The Red Hat Hybrid Cloud Console provides a set of cloud services, including Red Hat Insights and Subscriptions, that provide predictive analysis, remediation of issues, and unified subscription reporting for this Foreman instance.'
      )}
    </Text>
    <Text>
      {__(
        'The Foreman inventory upload plugin automatically uploads Foreman host inventory data to the Inventory service of Insights, where it can also be used by the Subscriptions service for subscription reporting. If you use the Subscriptions service, enabling inventory uploads is required.'
      )}
    </Text>
    <Text>
      <FormattedMessage
        id="enable-upload-hint"
        defaultMessage={__(
          'To enable this reporting for all Foreman organizations, set {uploadButtonName} to on. The data will be reported automatically once per day.'
        )}
        values={{
          uploadButtonName: <strong>{__('Automatic inventory upload')}</strong>,
        }}
      />
    </Text>
    <Text>
      <FormattedMessage
        id="restart-button-hint"
        defaultMessage={__(
          'To manually upload the data for a specific organization, select an organization and click {restartButtonName}.'
        )}
        values={{
          restartButtonName: (
            <strong>{__('Generate and upload report')}</strong>
          ),
        }}
      />
    </Text>
    <Text>
      {__('For more information about the Subscriptions service, see:')}
      &nbsp;
      <a
        href="https://docs.redhat.com/en/documentation/subscription_central/1-latest/html/getting_started_with_the_subscriptions_service/index"
        target="_blank"
        rel="noopener noreferrer"
      >
        {__('About subscription watch')}
      </a>
    </Text>
    <Text>
      {__('For more information about Insights and Cloud Connector, see:')}
      &nbsp;
      <a
        href="https://console.redhat.com/security/insights/"
        target="_blank"
        rel="noopener noreferrer"
      >
        {__('Red Hat Insights Data and Application Security')}
      </a>
    </Text>
  </div>
);

export default PageDescription;
