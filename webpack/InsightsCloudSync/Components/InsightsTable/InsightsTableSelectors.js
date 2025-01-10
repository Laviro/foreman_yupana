import URI from 'urijs';
import { STATUS } from 'foremanReact/constants';
import { selectRouterLocation } from 'foremanReact/routes/RouterSelector';
import {
  selectAPIResponse,
  selectAPIStatus,
  selectAPIErrorMessage,
} from 'foremanReact/redux/API/APISelectors';
import { ADVISOR_ENGINE_CONFIG_KEY, INSIGHTS_HITS_API_KEY } from './InsightsTableConstants';
import { selectInsightsCloudSync } from '../../../ForemanRhCloudSelectors';

export const selectQuery = state => selectRouterLocation(state).query;

export const selectSearch = state => {
  const { search = '' } = selectQuery(state);
  return URI.decodeQuery(search);
};

export const selectPage = state => {
  const { page = '1' } = selectQuery(state);
  return Number(page);
};

export const selectPerPage = state => {
  const perPage = selectQuery(state).per_page;
  return perPage && Number(perPage);
};

export const selectQueryParams = state => ({
  page: selectPage(state),
  perPage: selectPerPage(state),
  query: selectSearch(state),
  sortBy: selectSortBy(state),
  sortOrder: selectSortOrder(state),
  isSelectAll: selectIsAllSelectedQuery(state),
});

export const selectStatus = state =>
  selectAPIStatus(state, INSIGHTS_HITS_API_KEY);

export const selectError = state =>
  selectAPIErrorMessage(state, INSIGHTS_HITS_API_KEY);

export const selectSortBy = state => {
  const sortBy = selectQuery(state).sort_by;
  return sortBy ? URI.decodeQuery(sortBy) : '';
};

export const selectSortOrder = state => {
  const sortOrder = selectQuery(state).sort_order;
  return sortOrder ? URI.decodeQuery(sortOrder) : '';
};

export const selectHits = state => {
  if (selectStatus(state) !== STATUS.RESOLVED) return [];
  return selectAPIResponse(state, INSIGHTS_HITS_API_KEY).hits || [];
};

export const selectInsightsCloudTable = state =>
  selectInsightsCloudSync(state).table || {};

export const selectSelectedIds = state =>
  selectInsightsCloudTable(state).selectedIds || {};

export const selectIsAllSelected = state =>
  selectInsightsCloudTable(state).isAllSelected || false;

export const selectIsAllSelectedQuery = state =>
  selectQuery(state).select_all === 'true';

export const selectShowSelectAllAlert = state =>
  selectInsightsCloudTable(state).showSelectAllAlert || false;

export const selectItemCount = state =>
  selectAPIResponse(state, INSIGHTS_HITS_API_KEY).itemCount || 0;
