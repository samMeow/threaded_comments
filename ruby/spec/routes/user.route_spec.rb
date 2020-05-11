# frozen_string_literal: true

require 'sequel'
require 'rack/test'

require_relative '../test.helper'
require_relative '../../routes/user.route'

describe UserRoute do
  attr_accessor :db
  describe 'get /users/:id' do
    before(:each) do
      @db = Sequel.mock
    end

    after(:each) do
      Sequel::Model.db = nil
    end

    it 'should get existing user correctly' do
      @db.fetch = { id: 1, name: 1 }
      @db.columns = %i[id name]
      Models::User.set_dataset(@db[:users])

      get '/users/1'
      expect(last_response.status).to equal(200)
      expect(last_response.body).to eq('{"id":1,"name":1}')
    end

    it 'should return 404 when user not exits' do
      Models::User.set_dataset(@db[:users])
      get '/users/2'
      expect(last_response.status).to equal(404)
      expect(last_response.body).to eq(
        '{"code":404,"message":"User 2 not found"}'
      )
    end
  end

  describe 'post /users' do
    before(:all) do
      @db = Sequel.mock
      @db.fetch = { id: 1, name: 'hello' }
      @db.columns = %i[id name]
      Models::User.set_dataset(@db[:users])
    end

    after(:all) do
      Sequel::Model.db = nil
    end

    it 'should reject empty body' do
      post '/users', {}.to_json, 'Content-Type' => 'application/json'
      expect(last_response.status).to equal(400)
      expect(JSON.parse(last_response.body)).to eq(
        'code' => 400,
        'message' => "The property \'#/\' did"\
        " not contain a required property of \'name\'"
      )
    end

    it 'should reject non-string name' do
      post '/users', { name: 123 }.to_json, 'Content-Type' => 'application/json'
      expect(last_response.status).to equal(400)
      expect(JSON.parse(last_response.body)).to eq(
        'code' => 400,
        'message' => "The property '#/name' of type integer"\
        ' did not match the following type: string'
      )
    end

    it 'should accept valid request' do
      post(
        '/users',
        { name: 'hello' }.to_json,
        'Content-Type' => 'application/json'
      )
      expect(last_response.status).to equal(200)
      expect(last_response.body).to eq('{"id":1,"name":"hello"}')
    end
  end

  describe 'update /users' do
    before(:all) do
      @db = Sequel.mock
    end

    after(:all) do
      Sequel::Model.db = nil
    end

    it 'should reject not exists users' do
      Models::User.set_dataset(@db[:users])
      put(
        '/users/1',
        { name: 'valid' }.to_json,
        'Content-Type' => 'application/json'
      )
      expect(last_response.status).to equal(404)
      expect(last_response.body).to eq(
        '{"code":404,"message":"User 1 not found"}'
      )
    end
  end
end
