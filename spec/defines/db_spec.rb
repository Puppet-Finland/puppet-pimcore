# frozen_string_literal: true

require 'spec_helper'

describe 'pimcore::db' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:title) { 'pimcore' }
      let(:facts) { os_facts }
      let(:params) do
        { 'user'     => 'pimcore',
          'password' => 'foobar', }
      end

      it { is_expected.to compile }
    end
  end
end
