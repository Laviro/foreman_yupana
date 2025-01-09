/* eslint-disable camelcase */
import URI from 'urijs';
import { NEW_HOST_PATH } from './InsightsTableConstants';

export const modifySelectedRows = (
  hits,
  selectedIds,
  showSelectAllAlert,
  hideHost
) => {
  if (hits.length === 0) return [];

  return hits
    .asMutable()
    .map(
      ({
        id,
        hostname,
        title,
        total_risk,
        has_playbook,
        results_url,
        solution_url,
      }) => {
        const disableCheckbox = !has_playbook;
        const cells = [hostname, title, total_risk, has_playbook, results_url];
        if (hideHost) cells.shift();
        return {
          cells,
          disableCheckbox,
          id,
          /** The main table checkbox will be seen as selected only if all rows are selected,
           * in this case we need to select also the disabled once and hide it with css */
          selected: selectedIds[id] || (disableCheckbox && showSelectAllAlert),
          recommendationUrl: results_url,
          accessRHUrl: solution_url,
        };
      }
    );
};

export const getSortColumnIndex = (columns, sortBy) => {
  let colIndex = 0;
  columns.forEach((col, index) => {
    if (col.sortKey === sortBy) {
      // The checkbox column shifts the data columns by 1;
      colIndex = index + 1;
    }
  });
  return colIndex;
};

export const getPerPageOptions = (urlPerPage, appPerPage) => {
  const initialValues = new Set([5, 10, 15, 25, 50]);
  initialValues.add(appPerPage);
  urlPerPage && initialValues.add(urlPerPage);
  const options = [...initialValues].sort((a, b) => a - b);
  return options.map(value => ({ title: value.toString(), value }));
};

export const isNewHostPage = () => {
  const uri = new URI();
  const pathname = uri.pathname();
  const isIncluded = pathname.includes(NEW_HOST_PATH);
  return isIncluded ? pathname.split('/new/hosts/')[1] : false; // return hostname or false
};

// return query or specific hostname with query if it's in the new host page.
export const getServerQueryForHostname = query => {
  const isNewHost = isNewHostPage();
  let serverQuery = query;
  if (isNewHost) {
    const hostQuery = `hostname = ${isNewHost}`;
    const q = query?.trim();
    serverQuery = q ? `${hostQuery} AND (${q})` : hostQuery;
  }
  return serverQuery;
};
