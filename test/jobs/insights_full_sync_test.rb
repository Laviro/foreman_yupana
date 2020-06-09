require 'test_helper'

class InsightsFullSyncTest < ActiveJob::TestCase
  setup do
    @host1 = FactoryBot.create(:host, :managed, name: 'host1')
    @host2 = FactoryBot.create(:host, :managed, name: 'host2')

    hits_json = <<-HITS_JSON
    [
        {
            "hostname": "#{@host1.name}",
            "rhel_version": "7.5",
            "uuid": "accdf444-5628-451d-bf3e-cf909ad72756",
            "last_seen": "2019-11-22T08:41:42.447244Z",
            "title": "New Ansible Engine packages are inaccessible when dedicated Ansible repo is not enabled",
            "solution_url": "",
            "total_risk": 2,
            "likelihood": 2,
            "publish_date": "2018-04-16T10:03:16Z",
            "results_url": "https://cloud.redhat.com/insights/overview/stability/ansible_deprecated_repo%7CANSIBLE_DEPRECATED_REPO/accdf444-5628-451d-bf3e-cf909ad72756/"
        },
        {
            "hostname": "#{@host1.name}",
            "rhel_version": "7.5",
            "uuid": "accdf444-5628-451d-bf3e-cf909ad72756",
            "last_seen": "2019-11-22T08:41:42.447244Z",
            "title": "CPU vulnerable to side-channel attacks using Microarchitectural Data Sampling (CVE-2018-12130, CVE-2018-12126, CVE-2018-12127, CVE-2019-11091)",
            "solution_url": "https://access.redhat.com/node/4134081",
            "total_risk": 2,
            "likelihood": 2,
            "publish_date": "2019-05-14T17:00:00Z",
            "results_url": "https://cloud.redhat.com/insights/overview/security/CVE_2018_12130_cpu_kernel%7CCVE_2018_12130_CPU_KERNEL_NEED_UPDATE/accdf444-5628-451d-bf3e-cf909ad72756/"
        },
        {
            "hostname": "#{@host2.name}",
            "rhel_version": "7.5",
            "uuid": "accdf444-5628-451d-bf3e-cf909ad72757",
            "last_seen": "2019-11-22T08:41:42.447244Z",
            "title": "CPU vulnerable to side-channel attacks using L1 Terminal Fault (CVE-2018-3620)",
            "solution_url": "https://access.redhat.com/node/3560291",
            "total_risk": 2,
            "likelihood": 2,
            "publish_date": "2018-08-14T17:00:00Z",
            "results_url": "https://cloud.redhat.com/insights/overview/security/CVE_2018_3620_cpu_kernel%7CCVE_2018_3620_CPU_KERNEL_NEED_UPDATE/accdf444-5628-451d-bf3e-cf909ad72756/"
        }
      ]
    HITS_JSON
    @hits = JSON.parse(hits_json)
  end

  test 'Hits data is replaced with data from cloud' do
    InsightsCloud::Async::InsightsFullSync.any_instance.expects(:query_insights_hits).returns(@hits)

    InsightsCloud::Async::InsightsFullSync.perform_now(@host1.organization)

    @host1.reload
    @host2.reload

    assert_equal 2, @host1.insights.hits.count
    assert_equal 1, @host2.insights.hits.count
  end
end
