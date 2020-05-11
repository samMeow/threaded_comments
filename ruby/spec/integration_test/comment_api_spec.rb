# frozen_string_literal: true

require 'sequel'

require_relative 'integration.helper'

describe 'Commont_API', integration: true do
  attr_accessor :db
  attr_accessor :user_id
  attr_accessor :thread_id

  describe 'GET /comments/list' do
    before(:each) do
      @db = Sequel::DATABASES[0]
      @user_id = @db[:users].insert({ name: 'user' })
      @thread_id = @db[:threads].insert({ title: 'thread' })
    end

    it 'should order response by root comment in create time' do
      comment_id = @db[:comments].insert(
        thread_id: @thread_id,
        user_id: @user_id,
        message: 'first'
      )
      c = @db[:comments].find(id: comment_id).first
      @db[:comments].insert({
                              thread_id: @thread_id,
                              user_id: @user_id,
                              parent_id: comment_id,
                              depth: 1,
                              parent_path: c[:path],
                              message: 'first-first'
                            })
      @db[:comments].insert(
        thread_id: @thread_id,
        user_id: @user_id,
        message: 'second'
      )

      get format(
        '/comments/list?thread_id=%<thread_id>s&limit=20',
        thread_id: @thread_id
      )
      expect(last_response.status).to equal(200)
      response = JSON.parse last_response.body
      expect(response['data'][0]['message']).to eq('second')
      expect(response['data'][1]['message']).to eq('first')
      expect(response['data'][2]['message']).to eq('first-first')
    end
  end

  describe 'GET /comments/listPopular' do
    before(:each) do
      @db = Sequel::DATABASES[0]
      @user_id = @db[:users].insert({ name: 'user' })
      @thread_id = @db[:threads].insert({ title: 'thread' })
    end

    it 'should order response by root comment in create time' do
      comment_id = @db[:comments].insert(
        thread_id: @thread_id,
        user_id: @user_id,
        message: 'first',
        upvote: 3,
        downvote: 1
      )
      c = @db[:comments].find(id: comment_id).first
      @db[:comments].insert({
                              thread_id: @thread_id,
                              user_id: @user_id,
                              parent_id: comment_id,
                              depth: 1,
                              parent_path: c[:path],
                              message: 'first-first',
                              upvote: 99
                            })
      @db[:comments].insert(
        thread_id: @thread_id,
        user_id: @user_id,
        message: 'second',
        upvote: 3
      )

      get format(
        '/comments/listPopular?thread_id=%<thread_id>s&limit=20',
        thread_id: @thread_id
      )
      expect(last_response.status).to equal(200)
      response = JSON.parse last_response.body
      expect(response['data'][0]['message']).to eq('second')
      expect(response['data'][0]['score']).to eq(3)
      expect(response['data'][1]['message']).to eq('first')
      expect(response['data'][1]['score']).to eq(2)
      expect(response['data'][2]['message']).to eq('first-first')
      expect(response['data'][2]['score']).to eq(99)
    end
  end
end
