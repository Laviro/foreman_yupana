import React, { useEffect, useContext } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import SwitcherPF4 from '../../../common/Switcher/SwitcherPF4';
import { InsightsConfigContext } from '../../InsightsCloudSync';
import './insightsSettings.scss';

const InsightsSettings = ({
  insightsSyncEnabled,
  getInsightsSyncSettings,
  setInsightsSyncEnabled,
}) => {
  const { isLocalInsightsAdvisor, setIsLocalInsightsAdvisor } = useContext(
    InsightsConfigContext
  );
  useEffect(() => {
    async function fetchData() {
      try {
        await getInsightsSyncSettings();
      } catch (err) {
        if (err.cause?.response?.status === 422) {
          setIsLocalInsightsAdvisor(true);
        } else {
          throw err;
        }
      }
    }
    fetchData();
  }, [getInsightsSyncSettings, setIsLocalInsightsAdvisor]);

  if (isLocalInsightsAdvisor) return null;

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
