import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import SwitcherPF4 from '../../../common/Switcher/SwitcherPF4';
import './insightsSettings.scss';
import { useAdvisorEngineConfig } from '../../../common/Hooks/ConfigHooks';

const InsightsSettings = ({
  insightsSyncEnabled,
  getInsightsSyncSettings,
  setInsightsSyncEnabled,
}) => {
  const isLocalAdvisorEngine = useAdvisorEngineConfig();
  useEffect(() => {
    getInsightsSyncSettings();
  }, [getInsightsSyncSettings]);

  if (isLocalAdvisorEngine) return null;

  return (
    <div className="insights_settings">
      <SwitcherPF4
        id="insights_sync_switcher"
        label={__('Sync automatically')}
        tooltip={__(
          'Enable automatic synchronization of Insights recommendations from the Red Hat cloud'
        )}
        isChecked={insightsSyncEnabled}
        onChange={() => setInsightsSyncEnabled(!insightsSyncEnabled)}
      />
    </div>
  );
};

InsightsSettings.propTypes = {
  insightsSyncEnabled: PropTypes.bool.isRequired,
  getInsightsSyncSettings: PropTypes.func.isRequired,
  setInsightsSyncEnabled: PropTypes.func.isRequired,
};

export default InsightsSettings;
