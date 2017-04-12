require 'sinatra'
require 'json'
require 'data_mapper'
require 'docdsl'

register Sinatra::DocDsl

page do
  title "TheGiftOfFood API docs"
  header 'API'
end

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

Dir["./app/models/*.rb"].each { |file| require file }
Dir["./app/helpers/*.rb"].each { |file| require file }
Dir["./app/controllers/*.rb"].each { |file| require file }

DataMapper.finalize
DataMapper.auto_migrate!

doc_endpoint '/doc'
