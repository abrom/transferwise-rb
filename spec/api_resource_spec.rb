require 'spec_helper'

describe Transferwise::APIResource do
  class Transferwise::Example < Transferwise::APIResource; end
  module Transferwise::Parent
    class ChildExample < Transferwise::APIResource; end
  end

  let(:klass) { described_class }

  describe '.class_name' do
    subject(:class_name) { klass.class_name }

    it { is_expected.to eq 'APIResource' }

    context 'Transferwise::Example class' do
      let(:klass) { Transferwise::Example }
      it { is_expected.to eq 'Example' }
    end

    context 'Transferwise::Parent::ChildExample class' do
      let(:klass) { Transferwise::Parent::ChildExample }
      it { is_expected.to eq 'ChildExample' }
    end
  end

  describe '.resource_url' do
    subject(:resource_url) { described_class.resource_url('some-id') }

    before { expect(described_class).to receive(:collection_url).and_return 'collection-url' }

    it { is_expected.to eq 'collection-url/some-id' }
  end

  describe '.collection_url' do
    subject(:collection_url) { klass.collection_url }

    it do
      expect { collection_url }.to(
        raise_error(
          NotImplementedError,
          'APIResource is an abstract class. You should perform actions on its subclasses (Account, Transfer, etc.)'
        )
      )
    end

    context 'Transferwise::Example class' do
      let(:klass) { Transferwise::Example }
      it { is_expected.to eq '/v1/examples' }
    end

    context 'Transferwise::Parent::ChildExample class' do
      let(:klass) { Transferwise::Parent::ChildExample }
      it { is_expected.to eq '/v1/childexamples' }
    end
  end

  shared_examples 'response parsed from request' do
    context 'response is a Hash' do
      it 'returns an instance of the calling class' do
        expect(Transferwise::Request).to receive(:request).and_return('foo' => 'bar')
        result = response
        expect(result).to be_a Transferwise::Example
        expect(result.foo).to eq 'bar'
      end
    end

    context 'response is an Array' do
      it 'returns an array of parsed responses' do
        expect(Transferwise::Request).to receive(:request).and_return [{ 'foo' => 'bar' }]
        result = response
        expect(result).to be_an Array
        expect(result.map(&:class)).to eq [Transferwise::Example]
        expect(result.first.foo).to eq 'bar'
      end
    end

    context 'an array of non-hashes' do
      it 'returns an array of strings' do
        expect(Transferwise::Request).to receive(:request).and_return ['Does not compute']
        expect(response).to eq ['Does not compute']
      end
    end

    context 'a non array/hash' do
      it 'returns the response verbatim' do
        expect(Transferwise::Request).to receive(:request).and_return 'Does not compute'
        expect(response).to eq 'Does not compute'
      end
    end

    context 'a nil response' do
      it 'returns the response verbatim' do
        expect(Transferwise::Request).to receive(:request).and_return nil
        expect(response).to be_nil
      end
    end
  end

  describe '.create' do
    subject(:create) { Transferwise::Example.create }

    it 'calls to Transferwise::Request with default params' do
      expect(Transferwise::Request).to receive(:request).with(:post, '/v1/examples', {}, {})
      create
    end

    context 'with params and options' do
      subject(:create) { Transferwise::Example.create({ name: 'Rose' }, access_token: 'abcd-1234') }

      it 'passes through provided arguments' do
        expect(Transferwise::Request).to(
          receive(:request).with(
            :post,
            '/v1/examples',
            { name: 'Rose'},
            { access_token: 'abcd-1234' }
          )
        )
        create
      end
    end

    it_behaves_like 'response parsed from request' do
      let(:response) { create }
    end
  end

  describe '.list' do
    subject(:list) { Transferwise::Example.list }

    it 'calls to Transferwise::Request with default params' do
      expect(Transferwise::Request).to receive(:request).with(:get, '/v1/examples', {}, {})
      list
    end

    context 'with params and options' do
      subject(:list) { Transferwise::Example.list({ name: 'Rose' }, access_token: 'abcd-1234') }

      it 'passes through provided arguments' do
        expect(Transferwise::Request).to(
          receive(:request).with(
            :get,
            '/v1/examples',
            { name: 'Rose'},
            { access_token: 'abcd-1234' }
          )
        )
        list
      end
    end

    context 'with params, options and resource ID' do
      subject(:list) { Transferwise::Example.list({ name: 'Rose' }, { access_token: 'abcd-1234' }, 7384) }

      it 'passes through provided arguments' do
        expect(Transferwise::Request).to(
          receive(:request).with(
            :get,
            '/v1/examples',
            { name: 'Rose'},
            { access_token: 'abcd-1234' }
          )
        )
        list
      end
    end

    context 'calling class overrides collection url to include resource ID' do
      subject(:list) do
        Transferwise::BorderlessAccount::Transaction.list({ name: 'Rose' }, { access_token: 'abcd-1234' }, 7384)
      end

      it 'passes through provided arguments' do
        expect(Transferwise::Request).to(
          receive(:request).with(
            :get,
            '/v1/borderless-accounts/7384/transactions',
            { name: 'Rose'},
            { access_token: 'abcd-1234' }
          )
        )
        list
      end
    end

    it_behaves_like 'response parsed from request' do
      let(:response) { list }
    end
  end

  describe '.get' do
    subject(:get) { Transferwise::Example.get(1234) }

    it 'calls to Transferwise::Request with default params' do
      expect(Transferwise::Request).to receive(:request).with(:get, '/v1/examples/1234', {}, {})
      get
    end

    context 'with options' do
      subject(:get) { Transferwise::Example.get(38367, access_token: 'abcd-1234') }

      it 'passes through provided arguments' do
        expect(Transferwise::Request).to(
          receive(:request).with(
            :get,
            '/v1/examples/38367',
            {},
            { access_token: 'abcd-1234' }
          )
        )
        get
      end
    end

    it_behaves_like 'response parsed from request' do
      let(:response) { get }
    end
  end
end
