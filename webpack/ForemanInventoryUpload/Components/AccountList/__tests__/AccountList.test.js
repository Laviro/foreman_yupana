import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

import AccountList from '../AccountList';
import { props } from '../AccountList.fixtures';

const fixtures = {
  'render with props': props,
  'show empty results': { ...props, filterTerm: 'not_matching_term' },
};

describe('AccountList', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(AccountList, fixtures));
});
