module ForemanInventoryUpload
  module Generators
    class Slice
      include FactHelpers

      attr_accessor :slice_id
      attr_reader :hosts_count

      def initialize(hosts, output = [], slice_id = Foreman.uuid)
        @stream = JsonStream.new(output)
        @hosts = hosts
        @slice_id = slice_id
        @hosts_count = 0
      end

      def render
        report_slice(@hosts)
        @stream.out
      end

      private

      def report_slice(hosts_batch)
        @stream.object do
          @stream.simple_field('report_slice_id', @slice_id)
          @stream.array_field('hosts', :last) do
            first = true
            hosts_batch.each do |host|
              next unless host&.subscription_facet
              @stream.comma unless first
              if report_host(host)
                first = false
                @hosts_count += 1
              end
            end
          end
        end
      end

      def report_host(host)
        @stream.object do
          @stream.simple_field('fqdn', host.fqdn)
          @stream.simple_field('account', account_id(host.organization).to_s)
          @stream.simple_field('subscription_manager_id', host.subscription_facet&.uuid)
          @stream.simple_field('satellite_id', host.subscription_facet&.uuid)
          @stream.simple_field('bios_uuid', fact_value(host, 'dmi::system::uuid'))
          @stream.simple_field('vm_uuid', fact_value(host, 'virt::uuid'))
          @stream.array_field('ip_addresses') do
            @stream.raw(host.interfaces.map do |nic|
              @stream.stringify_value(nic.ip) if nic.ip
            end.compact.join(', '))
          end
          @stream.array_field('mac_addresses') do
            @stream.raw(host.interfaces.map do |nic|
              @stream.stringify_value(nic.mac) if nic.mac
            end.compact.join(', '))
          end
          @stream.object_field('system_profile') do
            report_system_profile(host)
          end
          @stream.array_field('facts') do
            @stream.object do
              @stream.simple_field('namespace', 'satellite')
              @stream.object_field('facts', :last) do
                report_satellite_facts(host)
              end
            end
          end

          @stream.array_field('tags', :last) do
            report_tag('satellite', 'satellite_instance_id', Foreman.instance_id) if Foreman.respond_to?(:instance_id)
            report_tag('satellite', 'organization_id', host.organization_id.to_s, :last)
          end
        end
      end

      def report_tag(namespace, key, value, last = nil)
        @stream.object do
          @stream.simple_field('namespace', namespace)
          @stream.simple_field('key', key)
          @stream.simple_field('value', value, :last)
        end
        @stream.comma unless last
      end

      def report_system_profile(host)
        @stream.simple_field('number_of_cpus', fact_value(host, 'cpu::cpu(s)').to_i)
        @stream.simple_field('number_of_sockets', fact_value(host, 'cpu::cpu_socket(s)').to_i)
        @stream.simple_field('cores_per_socket', fact_value(host, 'cpu::core(s)_per_socket').to_i)
        @stream.simple_field('system_memory_bytes', kilobytes_to_bytes(fact_value(host, 'memory::memtotal').to_i))
        @stream.array_field('network_interfaces') do
          @stream.raw(host.interfaces.map do |nic|
            {
              'ipv4_addresses': [nic.ip].compact,
              'ipv6_addresses': [nic.ip6].compact,
              'mtu': nic.try(:mtu),
              'mac_address': nic.mac,
              'name': nic.identifier,
            }.compact.to_json
          end.join(', '))
        end
        @stream.simple_field('bios_vendor', fact_value(host, 'dmi::bios::vendor'))
        @stream.simple_field('bios_version', fact_value(host, 'dmi::bios::version'))
        @stream.simple_field('bios_release_date', fact_value(host, 'dmi::bios::relase_date'))
        if (cpu_flags = fact_value(host, 'lscpu::flags'))
          @stream.array_field('cpu_flags') do
            @stream.raw(cpu_flags.split.map do |flag|
              @stream.stringify_value(flag)
            end.join(', '))
          end
        end
        @stream.simple_field(
          'os_release',
          os_release_value(
            name: fact_value(host, 'distribution::name'),
            version: fact_value(host, 'distribution::version'),
            codename: fact_value(host, 'distribution::id')
          )
        )
        @stream.simple_field('os_kernel_version', fact_value(host, 'uname::release'))
        @stream.simple_field('arch', host.architecture&.name)
        @stream.simple_field('subscription_status', host.subscription_status_label)
        @stream.simple_field('katello_agent_running', host.content_facet&.katello_agent_installed?)
        @stream.simple_field('satellite_managed', true)
        @stream.simple_field(
          'infrastructure_type',
          ActiveModel::Type::Boolean.new.cast(fact_value(host, 'virt::is_guest')) ? 'virtual' : 'physical'
        )
        unless (installed_products = host.subscription_facet&.installed_products).empty?
          @stream.array_field('installed_products') do
            @stream.raw(installed_products.map do |product|
              {
                'name': product.name,
                'id': product.cp_product_id,
              }.to_json
            end.join(', '))
          end
        end
        @stream.array_field('installed_packages', :last) do
          first = true
          host.installed_packages.each do |package|
            @stream.raw("#{first ? '' : ', '}#{@stream.stringify_value(package.nvra)}")
            first = false
          end
        end
      end

      def report_satellite_facts(host)
        @stream.simple_field('virtual_host_name', host.subscription_facet&.hypervisor_host&.name)
        @stream.simple_field('virtual_host_uuid', host.subscription_facet&.hypervisor_host&.subscription_facet&.uuid)
        if defined?(ForemanThemeSatellite)
          @stream.simple_field('satellite_version', ForemanThemeSatellite::SATELLITE_VERSION)
        end
        @stream.simple_field('system_purpose_usage', host.subscription_facet.purpose_usage)
        @stream.simple_field('system_purpose_role', host.subscription_facet.purpose_role)
        @stream.simple_field('distribution_version', fact_value(host, 'distribution::version'))
        @stream.simple_field('satellite_instance_id', Foreman.try(:instance_id))
        @stream.simple_field('is_simple_content_access', golden_ticket?(host.organization))
        @stream.simple_field('organization_id', host.organization_id, :last)
      end

      def os_release_value(name:, version:, codename:)
        "#{name} #{version} (#{codename})"
      end
    end
  end
end
