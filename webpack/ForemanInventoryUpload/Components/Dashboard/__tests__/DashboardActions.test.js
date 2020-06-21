import { testActionSnapshotWithFixtures } from 'react-redux-test-utils';
import API from 'foremanReact/API';
import {
  startPolling,
  stopPolling,
  fetchLogs,
  setActiveTab,
  downloadReports,
  toggleFullScreen,
} from '../DashboardActions';
import {
  pollingProcessID,
  serverMock,
  activeTab,
  accountID,
} from '../Dashboard.fixtures';
import { rhCloudStateWrapper } from '../../../../ForemanRhCloudTestHelpers';

jest.mock('foremanReact/API');
API.get.mockImplementation(() => serverMock);

const runWithGetState = (state, action, params) => dispatch => {
  const getState = () => rhCloudStateWrapper({ dashboard: state });
  action(params)(dispatch, getState);
};

const fixtures = {
  'should startPolling': () => startPolling(accountID, pollingProcessID),
  'should fetchLogs': () =>
    runWithGetState({ activeTab: 'uploads' }, fetchLogs, accountID),
  'should stopPolling': () => stopPolling(accountID, pollingProcessID),
  'should setActiveTab': () => setActiveTab(accountID, activeTab),
  'should downloadReports': () => downloadReports(accountID),
  'should toggleFullScreen': () =>
    runWithGetState({ activeTab: 'reports' }, toggleFullScreen, accountID),
};

describe('Dashboard actions', () => testActionSnapshotWithFixtures(fixtures));
