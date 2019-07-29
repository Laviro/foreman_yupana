import Immutable from 'seamless-immutable';

import {
  YUPANA_POLLING_START,
  YUPANA_POLLING,
  YUPANA_TAB_CHANGED,
  YUPANA_POLLING_ERROR,
  YUPANA_QUEUE,
  YUPANA_QUEUE_ERROR,
} from './DashboardConstants';
import { seperator } from './DashboardHelper';

const initialState = Immutable({
  /** insert Dashboard state here */
  generating: {
    logs: ['No running process', seperator],
    completed: 0,
    error: null,
  },
  uploading: {
    logs: ['No running process', seperator],
    completed: 0,
    files: {
      queue: [],
      error: null,
    },
    error: null,
  },
  pollingProcessID: 0,
  activeTab: 'uploads',
});

export default (state = initialState, action) => {
  const { payload } = action;
  const activeTab = state.activeTab === 'reports' ? 'generating' : 'uploading';
  switch (action.type) {
    case YUPANA_POLLING_START:
      return state.merge({
        pollingProcessID: payload.pollingProcessID,
      });
    case YUPANA_POLLING:
      return state.setIn([activeTab], {
        ...state[activeTab],
        ...payload,
      });
    case YUPANA_TAB_CHANGED:
      return state.merge({
        activeTab: payload.activeTab,
      });
    case YUPANA_POLLING_ERROR:
      return state.setIn([activeTab], {
        ...state[activeTab],
        error: payload.error,
      });
    case YUPANA_QUEUE:
      return state.setIn(['uploading'], {
        ...state.uploading,
        files: {
          ...state.uploading.files,
          queue: payload.queue,
        },
      });
    case YUPANA_QUEUE_ERROR:
      return state.setIn(['uploading'], {
        ...state.uploading,
        files: {
          ...state.uploading.files,
          error: payload.error,
        },
      });
    default:
      return state;
  }
};
