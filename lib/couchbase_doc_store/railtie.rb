require 'rails'
require 'couchbase_doc_store'

module CouchbaseSettings
  class Railtie < Rails::Railtie
    config.after_configuration do
      CouchbaseDocStore.connect!
    end
  end
end