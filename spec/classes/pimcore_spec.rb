# frozen_string_literal: true

require 'spec_helper'

describe 'pimcore' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge({ root_home: '/root' }) }
      let(:params) do
        { 'admin_user'     => 'pimcore-admin',
          'admin_password' => 'foobar',
          'root_db_pass'   => 'foobar',
          'db_password'    => 'foobar', }
      end

      it { is_expected.to compile }
    end
  end
end
