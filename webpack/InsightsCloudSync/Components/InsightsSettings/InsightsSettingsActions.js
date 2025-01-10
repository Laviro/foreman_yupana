import { API } from 'foremanReact/redux/API';
import { addToast } from 'foremanReact/components/ToastsList';
import { insightsCloudUrl } from '../../InsightsCloudSyncHelpers';
import {
  INSIGHTS_SYNC_SETTING_SET,
  INSIGHTS_SYNC_SETTINGS_GET_SUCCESS,
} from './InsightsSettingsConstants';

export const getInsightsSyncSettings = () => async dispatch => {
  try {
    const {
      data: { insightsSyncEnabled },
    } = await API.get(insightsCloudUrl('settings'));
    dispatch({
      type: INSIGHTS_SYNC_SETTINGS_GET_SUCCESS,
      payload: {
        settings: {
          insightsSyncEnabled,
        },
      },
    });
  } catch (err) {
    const { message } = err;
    dispatch(
      addToast({
        sticky: true,
        type: 'error',
        message,
      })
    );
  }
};

export const setInsightsSyncEnabled = currentInsightsSyncEnabled => async dispatch => {
  try {
    const {
      data: { insightsSyncEnabled },
    } = await API.patch(insightsCloudUrl('settings'), {
      insightsSyncEnabled: currentInsightsSyncEnabled,
    });
    dispatch({
      type: INSIGHTS_SYNC_SETTING_SET,
      payload: {
        settings: {
          insightsSyncEnabled,
        },
      },
    });
  } catch ({ message }) {
    dispatch(
      addToast({
        sticky: true,
        type: 'error',
        message,
      })
    );
  }
};
