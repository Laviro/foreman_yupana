require 'test_plugin_helper'

class ReportGeneratorTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by(login: 'secret_admin')

    env = FactoryBot.create(:katello_k_t_environment)
    cv = env.content_views << FactoryBot.create(:katello_content_view, organization: env.organization)

    @host = FactoryBot.create(
      :host,
      :with_subscription,
      :with_content,
      content_view: cv.first,
      lifecycle_environment: env,
      organization: env.organization
    )

    @host.organization.pools << FactoryBot.create(:katello_pool, account_number: '1234', cp_id: 1)

    ForemanInventoryUpload::Generators::Queries.instance_variable_set(:@fact_names, nil)
  end

  def interesting_facts
    [
      'dmi::system::uuid',
      'virt::uuid',
      'cpu::cpu(s)',
      'cpu::cpu_socket(s)',
      'cpu::core(s)_per_socket',
      'memory::memtotal',
      'dmi::bios::vendor',
      'dmi::bios::version',
      'dmi::bios::relase_date',
      'uname::release',
      'lscpu::flags',
      'distribution::name',
      'distribution::version',
      'distribution::id',
      'virt::is_guest',
    ]
  end

  def fact_names
    @fact_names ||= Hash[
      interesting_facts.map do |fact|
        [fact, FactoryBot.create(:fact_name, name: fact, type: 'Katello::RhsmFactName')]
      end
    ]
  end

  test 'generates a report for a single host' do
    batch = Host.where(id: @host.id).in_batches.first
    generator = create_generator(batch)

    json_str = generator.render
    actual = JSON.parse(json_str.join("\n"))

    assert_equal 'slice_123', actual['report_slice_id']
    assert_not_nil(actual_host = actual['hosts'].first)
    assert_equal @host.name, actual_host['display_name']
    assert_equal @host.fqdn, actual_host['fqdn']
    assert_equal '1234', actual_host['account']
    assert_equal 1, generator.hosts_count
  end

  test 'generates a report with satellite facts' do
    Foreman.expects(:instance_id).twice.returns('satellite-id')
    batch = Host.where(id: @host.id).in_batches.first
    generator = create_generator(batch)

    json_str = generator.render
    actual = JSON.parse(json_str.join("\n"))

    facts = actual['hosts'].first['facts'].first
    assert_equal 'satellite', facts['namespace']
    satellite_facts = facts['facts']
    assert_equal 'satellite-id', satellite_facts['satellite_instance_id']
    assert_equal @host.organization_id, satellite_facts['organization_id']

    instance_id_tag = actual['hosts'].first['tags'].find { |tag| tag['namespace'] == 'satellite' && tag['key'] == 'satellite_instance_id'}
    assert_not_nil instance_id_tag
    assert_equal 'satellite-id', instance_id_tag['value']

    org_id_tag = actual['hosts'].first['tags'].find { |tag| tag['namespace'] == 'satellite' && tag['key'] == 'organization_id'}
    assert_not_nil org_id_tag
    assert_equal @host.organization_id.to_s, org_id_tag['value']

    version = satellite_facts['satellite_version']
    if defined?(ForemanThemeSatellite)
      assert_equal ForemanThemeSatellite::SATELLITE_VERSION, version
    else
      assert_nil version
    end
  end

  test 'generates a report for a host with hypervisor' do
    hypervisor_host = FactoryBot.create(
      :host,
      :with_subscription,
      :with_content,
      content_view: @host.content_view,
      lifecycle_environment: @host.lifecycle_environment,
      organization: @host.organization
    )

    @host.subscription_facet.hypervisor_host = hypervisor_host
    @host.save!

    batch = Host.where(id: @host.id).in_batches.first
    generator = create_generator(batch)

    json_str = generator.render
    actual = JSON.parse(json_str.join("\n"))

    assert_equal 'slice_123', actual['report_slice_id']
    assert_not_nil(actual_host = actual['hosts'].first)
    assert_equal @host.name, actual_host['display_name']
    assert_equal @host.fqdn, actual_host['fqdn']
    assert_not_nil(host_facts = actual_host['facts']&.first)
    assert_equal 'satellite', host_facts['namespace']
    assert_not_nil(fact_values = host_facts['facts'])
    assert_equal hypervisor_host.name, fact_values['virtual_host_name']
    assert_equal hypervisor_host.subscription_facet.uuid, fact_values['virtual_host_uuid']
  end

  test 'generates a report with system purpose' do
    @host.subscription_facet.purpose_usage = 'test_usage'
    @host.subscription_facet.purpose_role = 'test_role'
    @host.subscription_facet.save!

    batch = Host.where(id: @host.id).in_batches.first
    generator = create_generator(batch)

    json_str = generator.render
    actual = JSON.parse(json_str.join("\n"))

    assert_equal 'slice_123', actual['report_slice_id']
    assert_not_nil(actual_host = actual['hosts'].first)
    assert_equal @host.name, actual_host['display_name']
    assert_equal @host.fqdn, actual_host['fqdn']
    assert_not_nil(host_facts = actual_host['facts']&.first)
    assert_equal 'satellite', host_facts['namespace']
    assert_not_nil(fact_values = host_facts['facts'])
    assert_equal 'test_usage', fact_values['system_purpose_usage']
    assert_equal 'test_role', fact_values['system_purpose_role']
  end

  test 'generates a report for a golden ticket' do
    batch = Host.where(id: @host.id).in_batches.first
    generator = create_generator(batch) do |generator|
      generator.stubs(:golden_ticket?).returns(true)
    end

    json_str = generator.render
    actual = JSON.parse(json_str.join("\n"))

    assert_equal 'slice_123', actual['report_slice_id']
    assert_not_nil(actual_host = actual['hosts'].first)
    assert_equal @host.name, actual_host['display_name']
    assert_equal @host.fqdn, actual_host['fqdn']
    assert_equal '1234', actual_host['account']
    assert_equal 1, generator.hosts_count
  end

  test 'skips hosts without subscription' do
    a_host = FactoryBot.create(
      :host,
      organization: @host.organization
    )

    # make a_host last
    batch = Host.where(id: [@host.id, a_host.id]).order(:name).in_batches.first
    generator = create_generator(batch)

    json_str = generator.render
    actual = JSON.parse(json_str.join("\n"))

    assert_equal 'slice_123', actual['report_slice_id']
    assert_not_nil(actual_host = actual['hosts'].first)
    assert_equal @host.name, actual_host['display_name']
    assert_equal @host.fqdn, actual_host['fqdn']
    assert_equal '1234', actual_host['account']
    assert_equal 1, generator.hosts_count
  end

  test 'shows system_memory_bytes in bytes' do
    FactoryBot.create(:fact_value, fact_name: fact_names['memory::memtotal'], value: '1', host: @host)

    batch = Host.where(id: @host.id).in_batches.first
    generator = create_generator(batch)

    json_str = generator.render
    actual = JSON.parse(json_str.join("\n"))

    assert_equal 'slice_123', actual['report_slice_id']
    assert_not_nil(actual_host = actual['hosts'].first)
    assert_not_nil(actual_profile = actual_host['system_profile'])
    assert_equal 1024, actual_profile['system_memory_bytes']
  end

  test 'reports an account for hosts with multiple pools' do
    first_pool = @host.organization.pools.first
    second_pool = FactoryBot.create(:katello_pool, account_number: nil, cp_id: 2)
    new_org = FactoryBot.create(:organization, pools: [first_pool, second_pool])
    @host.organization = new_org
    @host.save!

    batch = Host.where(id: @host.id).in_batches.first
    generator = create_generator(batch)

    json_str = generator.render
    actual = JSON.parse(json_str.join("\n"))

    assert_equal 'slice_123', actual['report_slice_id']
    assert_not_nil(actual_host = actual['hosts'].first)
    assert_not_nil(actual_host['account'])
    assert_not_empty(actual_host['account'])
  end

  test 'Generates os_release with version and id' do
    FactoryBot.create(:fact_value, fact_name: fact_names['distribution::name'], value: 'Red Hat Test Linux', host: @host)
    FactoryBot.create(:fact_value, fact_name: fact_names['distribution::version'], value: '7.1', host: @host)
    FactoryBot.create(:fact_value, fact_name: fact_names['distribution::id'], value: 'TestId', host: @host)

    batch = Host.where(id: @host.id).in_batches.first
    generator = create_generator(batch)

    json_str = generator.render
    actual = JSON.parse(json_str.join("\n"))

    assert_equal 'slice_123', actual['report_slice_id']
    assert_not_nil(actual_host = actual['hosts'].first)
    assert_not_nil(actual_profile = actual_host['system_profile'])
    assert_equal 'Red Hat Test Linux 7.1 (TestId)', actual_profile['os_release']
  end

  test 'sets infrastructure_type to "virtual" based on virt.is_guest fact' do
    FactoryBot.create(:fact_value, fact_name: fact_names['virt::is_guest'], value: true, host: @host)

    batch = Host.where(id: @host.id).in_batches.first
    generator = create_generator(batch)

    json_str = generator.render
    actual = JSON.parse(json_str.join("\n"))

    assert_equal 'slice_123', actual['report_slice_id']
    assert_not_nil(actual_host = actual['hosts'].first)
    assert_not_nil(actual_profile = actual_host['system_profile'])
    assert_equal 'virtual', actual_profile['infrastructure_type']
  end

  test 'sets infrastructure_type to "physical" based on virt.is_guest fact' do
    FactoryBot.create(:fact_value, fact_name: fact_names['virt::is_guest'], value: false, host: @host)

    batch = Host.where(id: @host.id).in_batches.first
    generator = create_generator(batch)

    json_str = generator.render
    actual = JSON.parse(json_str.join("\n"))

    assert_equal 'slice_123', actual['report_slice_id']
    assert_not_nil(actual_host = actual['hosts'].first)
    assert_not_nil(actual_profile = actual_host['system_profile'])
    assert_equal 'physical', actual_profile['infrastructure_type']
  end

  private

  def create_generator(batch, name = 'slice_123')
    generator = ForemanInventoryUpload::Generators::Slice.new(batch, [], name)
    if block_given?
      yield(generator)
    else
      generator.stubs(:golden_ticket?).returns(false)
    end
    generator
  end
end
